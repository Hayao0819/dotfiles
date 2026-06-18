# LaTeX templating (Phase 4)

The user provides the conference template. Fill it section by section; never
invent a template or restructure the user's one.

## Drafting order (write-backwards / results-first)

Draft into the template in this order so motivation matches payoff:
conclusion → results → methods → discussion → introduction → abstract → title.
(See story-outline.md.) Synthesis-heavy sections (related work, discussion):
prefer edit-not-write — the human drafts, the skill adds inline comments.

## Per-section fill + compile/lint loop

1. Read the template's section structure and required macros/classes.
2. Fill one section from its paragraph specs (templates/paragraph-spec.md).
3. Compile; feed errors back and fix; lint (e.g. ChkTeX) and fix.
4. Move to the next section only when it compiles clean.

Long-output rule: write section text directly to the `.tex` file with Write/Edit;
do not dump full drafts into chat (avoids the output-token cap). Show only a
one-paragraph summary per section. For parallel drafting, isolate agents in
separate git worktrees.

## Citations / BibTeX

`\cite` keys resolve only to verified `.bib` entries fetched by
`scripts/fetch_bibtex.py` (see citation-gate.md). A final sweep confirms every
`\cite{key}` maps to a verified entry; an orphan key blocks the build.

## Math, figures, captions

- Integrate equations grammatically; define each symbol once; don't narrate
  symbol-by-symbol.
- Captions are self-contained and add information beyond the body (axes, units,
  takeaway); never paraphrase the referencing sentence.

## Output

- Paper → LaTeX → PDF.
- Slides: hand off to the hayao-slides repo (Marp + touseki-v1) — use its
  `outline` skill for structure, then `create-slide`. Do not build slides here.

## Notes

- The unicode/formatting-residue check (natural-writing "Machine residue") matters
  in LaTeX: literal markdown (`**`, `#`), curly quotes, and U+202F/U+200B injected
  by the model break LaTeX or render wrong.
