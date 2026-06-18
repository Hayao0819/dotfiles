#!/usr/bin/env python3
"""Verify a citation candidate pool against authoritative APIs.

A citation passes ONLY if title + first-author surname + year all match a real
record. A resolving DOI alone is not enough (64% of fabricated DOIs resolve to an
unrelated real paper). CS venues are checked against DBLP, everything else against
Crossref; Crossref ranking is loose, so the returned record is fuzzy-matched back
to the claimed metadata. Standard library only.

Usage:
    python verify_citations.py --pool pool.json [--strict]

pool.json: a JSON list of objects, each:
    {"id": "...", "title": "...", "authors": ["First Last", ...], "year": 2017,
     "doi": "...", "dblp_key": "...", "venue": "..."}

Prints a per-entry verdict table and a summary. With --strict, exits 1 if any
entry is not 'verified'. Set PAPER_WRITING_MAILTO for the polite pool.
"""
import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from difflib import SequenceMatcher

MAIL = os.environ.get("PAPER_WRITING_MAILTO", "")
UA = f"paper-writing-skill/1.0 (mailto:{MAIL})" if MAIL else "paper-writing-skill/1.0"
TITLE_THRESHOLD = 0.90


def _get_json(url, timeout=30):
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8", "replace"))


def norm(s):
    return re.sub(r"\s+", " ", re.sub(r"[^0-9a-z぀-ヿ一-鿿 ]", " ", (s or "").lower())).strip()


def title_sim(a, b):
    return SequenceMatcher(None, norm(a), norm(b)).ratio()


def surname(author):
    parts = (author or "").replace(",", " ").split()
    return parts[-1].lower() if parts else ""


def check_crossref(entry):
    q = urllib.parse.urlencode({"query.bibliographic": entry.get("title", ""), "rows": 5,
                                **({"mailto": MAIL} if MAIL else {})})
    data = _get_json(f"https://api.crossref.org/works?{q}")
    best = None
    for it in data.get("message", {}).get("items", []):
        cand = (it.get("title") or [""])[0]
        sim = title_sim(entry.get("title", ""), cand)
        if best is None or sim > best[0]:
            ry = ((it.get("published") or it.get("issued") or {}).get("date-parts") or [[None]])[0][0]
            auths = [f"{a.get('given','')} {a.get('family','')}" for a in it.get("author", []) or []]
            best = (sim, cand, ry, auths, it.get("DOI"))
    return best


def check_dblp(entry):
    q = urllib.parse.urlencode({"q": entry.get("title", ""), "format": "json", "h": 5})
    data = _get_json(f"https://dblp.org/search/publ/api?{q}")
    hits = data.get("result", {}).get("hits", {}).get("hit", [])
    best = None
    for h in hits:
        info = h.get("info", {})
        sim = title_sim(entry.get("title", ""), info.get("title", ""))
        if best is None or sim > best[0]:
            au = info.get("authors", {}).get("author", [])
            au = au if isinstance(au, list) else [au]
            auths = [a.get("text", "") if isinstance(a, dict) else str(a) for a in au]
            best = (sim, info.get("title", ""), info.get("year"), auths, info.get("doi"))
    return best


def verify(entry):
    use_dblp = bool(entry.get("dblp_key")) or "dblp" in (entry.get("venue", "").lower())
    try:
        best = check_dblp(entry) if use_dblp else check_crossref(entry)
        if best is None:
            best = check_crossref(entry) if use_dblp else check_dblp(entry)
    except (urllib.error.URLError, urllib.error.HTTPError, json.JSONDecodeError) as e:
        return "error", [], f"API failure: {e}"
    if not best:
        return "unverified", [], "no candidate found"
    sim, cand, ry, auths, _doi = best
    matched = []
    if sim >= TITLE_THRESHOLD:
        matched.append("title")
    try:
        if entry.get("year") and ry and abs(int(entry["year"]) - int(ry)) <= 1:
            matched.append("year")
    except (TypeError, ValueError):
        pass
    want = surname(entry.get("authors", [""])[0]) if entry.get("authors") else ""
    if want and any(want == surname(a) for a in auths):
        matched.append("first_author")
    ok = {"title", "year", "first_author"}.issubset(set(matched))
    note = f"title~{sim:.2f} vs {cand[:60]!r}"
    return ("verified" if ok else "rejected" if "title" in matched else "unverified"), matched, note


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--pool", required=True)
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()
    try:
        with open(args.pool, encoding="utf-8") as f:
            pool = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"ERROR: cannot read pool: {e}", file=sys.stderr)
        return 2
    counts = {"verified": 0, "rejected": 0, "unverified": 0, "error": 0}
    print(f"{'id':<18} {'status':<11} matched / note")
    print("-" * 78)
    for e in pool:
        status, matched, note = verify(e)
        counts[status] += 1
        eid = (e.get("id") or e.get("title", "?"))[:17]
        print(f"{eid:<18} {status:<11} {'+'.join(matched) or '-'} | {note}")
    print("-" * 78)
    print(" ".join(f"{k}={v}" for k, v in counts.items()))
    if args.strict and (counts["rejected"] or counts["unverified"] or counts["error"]):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
