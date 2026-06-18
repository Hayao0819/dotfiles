# Anti-hallucination: rationale and stance

## Why the hard rules exist

- **Fabricated citations** run 18–55% unconstrained, higher on niche topics, and
  metadata errors hit 24–45% of even real ones; 64% of fake DOIs resolve to an
  unrelated real paper. Hundreds of published papers already contain hallucinated
  citations (Walters & Wilder 2023; Lancet audit; CiteCheck 2605.27700).
- **Prompt-level "don't fabricate" instructions are unreliable** and can hide
  fabrication — temporal/survey constraints dropped verified-citation rates to
  ~2–12% while keeping references correctly formatted (deployment-constraints
  study, arXiv 2603.07287). So external verification + human review are mandatory,
  never optional.
- **Invented jargon**: LLMs paper over a knowledge gap with a confident-sounding
  coined term, or reuse a context-only term as if established (neologism work,
  arXiv 2502.07586). Detect by grounding, not style: a term is either attestable
  in the literature (citable) or introduced here with a definition + novelty flag.
- **Correct ≠ faithful**: up to 57% of citations are post-rationalized (real
  source, doesn't support the claim). Hence the faithfulness gate (quote+locator).

## Knowledge Isolation Directive

Factual content — claims, citations, data, methods — comes only from session
materials. If the outline needs something the materials don't cover, output
`[MATERIAL GAP]`, never fill from memory. The writing skill is unrestricted; only
factual content is restricted. The Methods section describes only what the user's
materials document — do not infer or interpolate procedures. (imbad0202
anti_leakage_protocol; PaperOrchestra.)

## This is NOT an AI humanizer or detector-evasion tool

The goal is genuine prose quality — clarity, precision, verified claims, authentic
voice — not making text "undetectable". Never use the humanizer playbook:
synonym-spinning, sentence-shuffling for statistical cover, perplexity/burstiness
manipulation, injected typos or filler, paraphrase loops, or optimizing against AI
detectors. These demonstrably degrade fluency and distort meaning (DAMAGE / ACL
GenAIDetect 2025), detector evasion is an unreliable arms race, and deliberately
hiding AI use runs against COPE/ICMJE/publisher transparency requirements.

Do NOT over-correct: inflating formality, uniformity, or vocabulary to "sound
academic" reads MORE like AI and trips false positives (esp. non-native English;
Liang et al., Patterns 2023, 61.3% vs 5.1%). Detector scores are not evidence.
Optimize for specificity and voice.

> 本スキルは検出回避ツールではない。目的は検出を逃れることではなく、明瞭性・
> 正確性・検証済みの主張・著者の声という本質的な品質。humanizer の手口は使わ
> ない。AI 利用は投稿先の方針に従って開示し、すべての主張の責任は著者が負う。

Disclose AI assistance per the target venue's policy; the human author remains
responsible for every claim.
