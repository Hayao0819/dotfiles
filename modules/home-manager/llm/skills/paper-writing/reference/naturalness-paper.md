# Paper-specific naturalness (Phase 6)

natural-writing owns the generic anti-LLM checklist (excess vocab, em-dash,
translationese, chatbot residue, Unicode artifacts). This file covers only what
is specific to academic papers. Run natural-writing first, then this.

## Excess vocabulary — with a discipline-exception clause

Treat these as priors to de-weight, NOT a find-and-replace. Flag if frequency is
unnatural; keep a word when it is genuinely the field's term.

- EN style verbs/adjectives that spiked post-2023 (Kobak et al., Science Advances
  2025): delve, underscore, showcase, intricate, meticulous, pivotal, crucial,
  comprehensive, notably, leverage, foster, robust.
- **Discipline exceptions** (do not flag): "paradigm shift" in philosophy of
  science, "robust estimator" in statistics, literal "landscape" in ecology, etc.
- JP (handled mostly by natural-writing): 「本質的」「最適化」「重要である」 連発,
  「掘り下げる」「正面から」.

## Related work as synthesis, not a list

The one failure mode generic advice misses (shallow synthesis, arXiv 2402.12255):

- Write per theme, not per paper. Build a source × theme matrix first.
- Each related-work paragraph states how the cited works relate/contrast and ends
  on the gap that motivates this paper — not a summary of the last cited paper.
- Forbid the repeated "Author (Year) did X." list template. Use multi-cite
  parentheticals for agreement; narrative citation only for the contrast pivot.

## Structure-level checks

- **Topic-sentence test**: reading only the first sentence of each paragraph
  should yield a coherent argument outline (木下『理科系の作文技術』).
- **Per-section burstiness**: vary sentence length, but calibrate — Methods may be
  uniform (procedural); Discussion should vary most. Read aloud; fix if metronomic.
- **Hedging ladder**, matched to evidence: may/might < suggests/indicates <
  demonstrates/establishes. Don't hedge your own data/methods; don't flatten
  everything to one epistemic register.
- **Signposting cap**: ≤1 explicit roadmap sentence per major section (intro/
  methods only). Don't open consecutive paragraphs with transitions.
- **Contributions**: list only genuinely distinct, evidence-tied contributions —
  don't force three; don't inflate ablations/engineering into "contributions".
- **Abstract/intro clichés banned**: "In recent years", "With the rapid
  development of", 「近年〜が注目されている」. Lead with the finding; the gap names
  specific prior work and what it concretely fails to do.
- **Conclusion synthesizes**, not restates the abstract (delete-and-substitute
  test: if conclusion sentences could be replaced by the abstract with no loss,
  rewrite).
- **Substance ≥ polish**: treat smooth, well-formatted prose as a risk signal —
  verify every claim's grounding (PaperRecon: high presentation, 10+ hallucinations
  per paper).

Sources: Kobak et al. 2025; Jiang & Hyland 2025; shallow-synthesis 2402.12255;
Mensh & Kording 2017; 木下是雄『理科系の作文技術』.
