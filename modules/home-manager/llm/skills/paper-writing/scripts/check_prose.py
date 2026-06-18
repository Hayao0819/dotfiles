#!/usr/bin/env python3
"""Flag LLM tells in prose (paper text, commit messages, comments).

Heuristic and density-gated: this REPORTS, it does not auto-fix. The vocabulary
lists are priors, not proof — a flagged word may be the field's standard term
(see reference/naturalness-paper.md, discipline-exception clause). Standard
library only.

Usage:
    python check_prose.py FILE [FILE ...]
    python check_prose.py --max-per-1k 2 paper.tex

Reports, per file: chatbot residue (any = hard flag), Unicode artifacts (any),
em-dash density, and excess-vocabulary / Japanese-tell hits above the per-1000-
word threshold. Exit 1 if any hard flag (residue/Unicode) is found.
"""
import argparse
import re
import sys
import unicodedata

EN_VOCAB = [
    "delve", "delves", "delving", "underscore", "underscores", "showcase",
    "showcases", "showcasing", "intricate", "meticulous", "meticulously",
    "pivotal", "crucial", "comprehensive", "leverage", "leverages", "foster",
    "fosters", "robust", "seamless", "seamlessly", "multifaceted", "nuanced",
    "tapestry", "realm", "testament", "paramount", "notably", "moreover",
    "furthermore",
]
JP_VOCAB = [
    "することができ", "することが重要", "することが可能", "と言えるでしょう",
    "と考えられます", "重要です", "不可欠です", "包括的", "多角的", "最適化",
    "掘り下げ", "正面から", "において", "に他ならない",
]
RESIDUE = [
    "as an ai language model", "as a large language model", "certainly! here",
    "certainly, here", "sure, here's", "sure, here is", "i hope this helps",
    "as of my last knowledge update", "knowledge cutoff", "regenerate response",
    "もちろんです", "お役に立てれば幸いです",
]
# name -> codepoint for artifact characters models inject
UNICODE_ARTIFACTS = {
    "curly-double-quote": "“", "curly-double-quote-close": "”",
    "curly-single-quote": "‘", "curly-apostrophe": "’",
    "narrow-no-break-space": " ", "zero-width-space": "​",
    "em-space": " ",
}


def word_count(text):
    # ASCII words plus CJK characters (each CJK char counts as a word-ish unit)
    ascii_words = len(re.findall(r"[A-Za-z]+", text))
    cjk = len(re.findall(r"[぀-ヿ一-鿿]", text))
    return max(1, ascii_words + cjk)


def check(path, max_per_1k):
    try:
        with open(path, encoding="utf-8") as f:
            text = f.read()
    except OSError as e:
        print(f"ERROR: {path}: {e}", file=sys.stderr)
        return False, True
    low = text.lower()
    wc = word_count(text)
    scale = wc / 1000.0
    hard = False

    print(f"\n== {path}  ({wc} words) ==")

    residue = [p for p in RESIDUE if p in low]
    if residue:
        hard = True
        print("  [HARD] chatbot residue:", ", ".join(repr(r) for r in residue))

    arts = [name for name, ch in UNICODE_ARTIFACTS.items() if ch in text]
    if arts:
        hard = True
        print("  [HARD] unicode artifacts:", ", ".join(arts))

    em = text.count("—")
    if em and em / max(scale, 0.001) > 3:
        print(f"  [warn] em-dash density: {em} ({em / max(scale, 1):.1f}/1k, >3 is high)")

    def vocab_hits(words):
        hits = {}
        for w in words:
            n = low.count(w.lower())
            if n and n / max(scale, 0.001) > max_per_1k:
                hits[w] = n
        return hits

    en = vocab_hits(EN_VOCAB)
    jp = vocab_hits(JP_VOCAB)
    if en:
        print("  [vocab EN] over threshold:",
              ", ".join(f"{w}×{n}" for w, n in sorted(en.items(), key=lambda x: -x[1])))
    if jp:
        print("  [vocab JP] over threshold:",
              ", ".join(f"{w}×{n}" for w, n in sorted(jp.items(), key=lambda x: -x[1])))
    if not (residue or arts or en or jp):
        print("  ok (no flags above threshold)")
    return (bool(en or jp)), hard


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--max-per-1k", type=float, default=2.0,
                    help="vocab hits per 1000 words before flagging (default 2)")
    args = ap.parse_args()
    any_hard = False
    for path in args.files:
        _soft, hard = check(path, args.max_per_1k)
        any_hard = any_hard or hard
    print("\nNote: vocab flags are priors, not proof — keep a word when it is the"
          " field's genuine term (discipline exception).")
    return 1 if any_hard else 0


if __name__ == "__main__":
    sys.exit(main())
