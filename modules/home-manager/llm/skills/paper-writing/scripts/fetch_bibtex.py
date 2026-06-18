#!/usr/bin/env python3
"""Fetch a BibTeX entry from an authoritative API.

BibTeX must come from an API, never be written by the model (see
reference/citation-gate.md). Standard library only.

Usage:
    python fetch_bibtex.py --doi 10.1145/3292500.3330701
    python fetch_bibtex.py --dblp conf/nips/VaswaniSPUJGKP17
    python fetch_bibtex.py --arxiv 1706.03762

Set PAPER_WRITING_MAILTO=you@example.com for the polite pool.
Exit code 0 on success, 1 on failure (prints reason to stderr).
"""
import argparse
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

MAIL = os.environ.get("PAPER_WRITING_MAILTO", "")
UA = f"paper-writing-skill/1.0 (mailto:{MAIL})" if MAIL else "paper-writing-skill/1.0"


def _get(url, accept=None, timeout=30):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    if accept:
        req.add_header("Accept", accept)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read().decode("utf-8", "replace")


def from_doi(doi):
    doi = doi.strip().removeprefix("https://doi.org/").removeprefix("doi:")
    # Crossref/DataCite content negotiation
    return _get("https://doi.org/" + urllib.parse.quote(doi),
                accept="application/x-bibtex").strip()


def from_dblp(key):
    key = key.strip().removesuffix(".bib")
    return _get(f"https://dblp.org/rec/{key}.bib").strip()


def from_arxiv(aid):
    aid = aid.strip().removeprefix("arXiv:").removeprefix("arxiv:")
    atom = _get("http://export.arxiv.org/api/query?id_list=" + urllib.parse.quote(aid))
    ns = {"a": "http://www.w3.org/2005/Atom", "arxiv": "http://arxiv.org/schemas/atom"}
    entry = ET.fromstring(atom).find("a:entry", ns)
    if entry is None:
        raise ValueError(f"arXiv id not found: {aid}")
    # Prefer the published DOI when present (richer Crossref record)
    doi_el = entry.find("arxiv:doi", ns)
    if doi_el is not None and doi_el.text:
        return from_doi(doi_el.text)
    title = " ".join((entry.findtext("a:title", "", ns)).split())
    year = (entry.findtext("a:published", "", ns) or "")[:4]
    authors = [a.findtext("a:name", "", ns) for a in entry.findall("a:author", ns)]
    key = (authors[0].split()[-1] if authors else "arxiv") + year + aid.split(".")[0]
    return (
        f"@misc{{{key},\n"
        f"  title        = {{{title}}},\n"
        f"  author       = {{{' and '.join(authors)}}},\n"
        f"  year         = {{{year}}},\n"
        f"  eprint       = {{{aid}}},\n"
        f"  archivePrefix= {{arXiv}}\n"
        f"}}"
    )


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--doi")
    g.add_argument("--dblp")
    g.add_argument("--arxiv")
    args = ap.parse_args()
    try:
        if args.doi:
            out = from_doi(args.doi)
        elif args.dblp:
            out = from_dblp(args.dblp)
        else:
            out = from_arxiv(args.arxiv)
    except (urllib.error.URLError, urllib.error.HTTPError) as e:
        print(f"ERROR: network/API failure: {e}", file=sys.stderr)
        return 1
    except (ValueError, ET.ParseError) as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    if not out or "@" not in out:
        print("ERROR: no BibTeX returned (identifier may not exist)", file=sys.stderr)
        return 1
    print(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
