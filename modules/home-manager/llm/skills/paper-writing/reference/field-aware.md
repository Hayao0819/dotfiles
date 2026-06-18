# Field-aware guardrails (Phase 6)

LLM tells differ by field. Select by `outline.field`. Vocabulary lists decay
(authors now scrub "delve"), so these are structural, not lexical.

## CS / security / systems (USENIX Security, IEEE S&P, CCS, NDSS)

- **Explicit threat model**: attacker capabilities, assumptions, in-scope /
  out-of-scope. Never "potential attackers may…". These venues require it.
- **Motivation ↔ artifact consistency**: name a concrete, appropriate deployment
  target; don't motivate a heavyweight design with an inappropriate cheap target.
- **Falsifiable contributions**: each contribution is a claim an attack/defense
  result can falsify, not "a comprehensive study".
- **No "in today's digital landscape / increasingly critical" openers**; lead with
  the specific gap.
- **Evaluation honesty**: state base rate, dataset balance, and lab-vs-real-world
  explicitly.
Sources: USENIX Sec CFP; IEEE S&P CFP; CMU SOUPS "Common Pitfalls"; arXiv 2505.12700.

## Machine learning (NeurIPS, ICML, ICLR)

- Ban "we propose a novel framework", "remarkable success", "revolutionized",
  "in recent years".
- Each contribution is falsifiable with a number ("−40% memory", "+15% on C").
- Scope SOTA claims (which split, which baseline, tuned how); no bare
  "state-of-the-art".
- Tables report deltas with units, not "significantly outperforms"; ablations say
  what each component causes, not "demonstrates effectiveness".
- Related work by theme, not paper-by-paper.

## Biomedical / clinical (IMRaD, PubMed)

- The excess-vocabulary signal is strongest here — strip pivotal/crucial/intricate/
  delve/comprehensive unless statistically defined.
- Every quantitative claim carries n, effect size, CI/p, and the named test; flag
  any statistic the author can't point to in the data.
- Verify every reference resolves to a real DOI/PMID.
- Respect IMRaD boundaries (no results in Methods, no new claims in Discussion);
  limitations are concrete, not "further research is warranted".

## Humanities / social science

- A contestable thesis with a stance, not "this essay explores themes of".
- Close reading quotes specific text and interprets it; ban summary-as-analysis.
- Theory is applied to the object, not name-dropped ("through a Foucauldian lens"
  with no mechanism).
- Include genuine engagement (a real question, a situated authorial stance,
  counter-argument) — LLM essays are documented to under-use these (Jiang &
  Hyland 2025, engagement markers).

## Japanese domestic venues (e.g. CSS / 情報処理学会)

Follow the society's 執筆要項 and template. Apply natural-writing's Japanese pass
(である調 for papers, no です・ます mixing, translationese pass) plus the field
guardrails above for the technical content.
