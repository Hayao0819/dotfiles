---
name: paper-writing
description: >-
  Outline-and-story-first academic paper writing with hard anti-hallucination
  gates. Drafts a markdown bullet outline plus a first-time-reader story,
  reviews it with a context-isolated agent, then converts to LaTeX following a
  user-provided conference template. Verifies every citation against
  Crossref/DBLP/Semantic Scholar before it enters the paper, blocks invented
  jargon and fabricated numbers, and calls natural-writing for prose. Human in
  the loop with confirmation stops; not autonomous. English and Japanese. Use
  for 論文, conference submissions, related work, rebuttals, and research-based
  slides.
---

# Paper Writing

Build a bullet-point outline and a first-time-reader story first, confirm at
each step, then turn it into LaTeX for a user-provided conference template. The
overriding goal is to prevent fabricated citations and invented jargon.

## What this is, and is not

- Human in the loop. Each phase ends with a stop: present the result and wait
  for the user. Do not run research-to-final autonomously.
- If asked only to explain or to check a design, do that and nothing else. Do
  not jump ahead and start writing prose.
- Always apply the **natural-writing** skill to any prose this skill produces
  (it owns the generic anti-LLM checklist for English and Japanese). Use
  **deep-research** for source gathering. Run the heaviest proofreading pass on
  **Opus** (`claude-opus-4-8`).
- This is **not** an AI humanizer or detector-evasion tool. See
  [reference/anti-hallucination.md](reference/anti-hallucination.md).

## Material Passport (resumable state)

One paper = one directory, one git worktree. Never split one paper across
numbered directories. Keep `passport.yaml` as an append-only ledger linking:
research plan → citation candidate pool → paragraph specs → per-phase
confirmation state → verification results. This lets a session be interrupted,
resumed, or entered mid-pipeline. Schema:
[schemas/outline.schema.json](schemas/outline.schema.json) and
[schemas/citation.schema.json](schemas/citation.schema.json).

## Workflow

Each phase can be invoked on its own. Finish a phase, then stop for confirmation.

1. Research  2. Story / outline  3. Paragraph specs
4. Draft / LaTeX  5. Citation gate  6. Proofread

### Phase 1 — Research

Call **deep-research** to map the topic, prior work, and a citation candidate
pool. Every pool entry carries a stable id (DOI / arXiv / PMID / DBLP) and
API-derived canonical metadata. **Knowledge Isolation Directive**: factual
content — claims, citations, data, methods — comes only from session materials.
If the outline needs something the materials do not cover, write
`[MATERIAL GAP]` rather than filling it from memory. The writing skill is
unrestricted; only factual content is restricted.
→ Stop: confirm the pool and the research summary.

### Phase 2 — Story / outline

Write the whole structure as a markdown bullet list plus a first-time-reader
story, at coarse granularity (roughly "what goes in each section"). See
[reference/story-outline.md](reference/story-outline.md) (Context-Content-
Conclusion, write-backwards order). Then spawn a **context-isolated first-reader
agent** (a fresh agent that does NOT get this conversation's context) to audit
the flow of questions and flag undefined terms — see
[reference/context-isolation.md](reference/context-isolation.md). Tell the user
before launching that agent.
→ Stop: confirm structure, story, and the first-reader flags.

### Phase 3 — Paragraph specs

For each paragraph, write one line stating what it says and which pooled
citation supports it ([templates/paragraph-spec.md](templates/paragraph-spec.md)).
Do not write prose yet.
→ Stop: confirm the specs.

### Phase 4 — Draft / LaTeX

Draft from the specs. For synthesis-heavy sections (related work, discussion),
prefer **edit-not-write**: the human drafts, and this skill adds inline comments
on weak spots instead of replacing the prose, to keep the author's voice.
Default to **results-first / write-backwards** order: conclusion → results →
methods → discussion → intro → abstract → title.

Fill the user's conference template section by section and run a compile/lint
loop. Papers go to LaTeX→PDF; slides hand off to the hayao-slides repo. See
[reference/latex-templating.md](reference/latex-templating.md).

Long-output rule (required): write long body text directly to files with
Write/Edit; do not dump full drafts into chat — show only a one-paragraph
summary. This avoids losing a session to the output-token cap. When drafting in
parallel, isolate agents in separate git worktrees so they do not overwrite each
other.
→ Stop: confirm each section (show the diff plus flags only).

### Phase 5 — Citation gate (most important)

In-text citations may use only ids from the candidate pool. Anything without a
source becomes a `[CITATION NEEDED]` placeholder. Run
`scripts/verify_citations.py` to check every citation; fall back to the manual
curl procedure in [reference/citation-gate.md](reference/citation-gate.md) when
scripts can't run.

- **Existence**: match against Crossref → DBLP → Semantic Scholar → OpenAlex →
  arXiv. Never use Google Scholar as an authority (discovery only).
- **A resolving DOI is not enough**: match title + authors + year + venue +
  pages together (most fabricated DOIs resolve to an unrelated real paper).
- **Faithfulness**: confirm the cited work actually supports the claim. Attach a
  quote (≤25 words) and a locator. Reject post-hoc citations.
- **Authors and page numbers** must be checked explicitly (a frequent failure).
- **BibTeX** is fetched from an API, never written by the model
  (`scripts/fetch_bibtex.py`; DBLP `.bib` or Crossref content negotiation).
- **Distributional skew**: warn if ≥70% of cited sources share one
  year/region/method/venue.

Unverifiable citations leave the body and are surfaced as `UNVERIFIED`.
→ Stop: confirm the verified/rejected summary table.

### Phase 6 — Proofread

Apply natural-writing, then run a multi-dimension review with worktree-isolated
agents, each judged independently:

- **Logic / argumentation** ([reference/argumentation.md](reference/argumentation.md)):
  paragraph = one step of the argument; causal claims state the mechanism in one
  sentence; no lumping distinct causes; examples actually support the claim;
  forward references are paid off; never end on a concession; define terms before
  use.
- **Naturalness** ([reference/naturalness-paper.md](reference/naturalness-paper.md)):
  excess-vocabulary scan via `scripts/check_prose.py` (EN/JP, with a
  discipline-exception clause — keep field-standard terms; flags are priors, not
  proof), related work as synthesis not a list, topic-sentence
  test, per-section burstiness (Methods may be uniform, Discussion most varied),
  hedging ladder calibrated to evidence.
- **Field-aware** ([reference/field-aware.md](reference/field-aware.md)):
  CS/security (explicit threat model, motivation↔artifact, falsifiable
  contributions), ML, biomedical, humanities.
- **Citation consistency**: `\cite` ↔ `.bib`, no leftover `UNVERIFIED`.
- **LaTeX layout / slides**: floats, references, cross-deck duplication.

Then run an adversarial review of the central claim (Reviewer 2 / red-team) in a
separate agent. If draft↔critique do not converge in N rounds, escalate to the
user. Run the heaviest hallucination-checklist pass over the full text on Opus.
Treat smooth, well-formatted prose as a risk signal — verify every claim's
grounding.
→ Stop: present the review and required fixes.

## Hard rules (absolute)

See [reference/anti-hallucination.md](reference/anti-hallucination.md) for the
full rationale. Never relax these:

- No citation from memory in output. Pool-derived and verified only.
- No invented jargon. A technical term is either attestable in existing
  literature (citable) or introduced by this paper with a definition and a
  novelty flag. Otherwise ask the user.
- No fabricated statistics, numbers, datasets, equations, or tools. Unknowns
  become `[UNVERIFIED]`.
- Do not rely on prompt-level "don't fabricate" instructions — always go through
  external verification and human review.
- No detector-evasion. Optimize for genuine quality, not for "looking human".

## Files

- `reference/` — story-outline, context-isolation, citation-gate, argumentation,
  naturalness-paper, field-aware, latex-templating, anti-hallucination
- `schemas/` — outline.schema.json, citation.schema.json
- `scripts/` — verify_citations.py, fetch_bibtex.py, check_prose.py
- `templates/` — paragraph-spec.md
- `passport.yaml` — runtime state (gitignored)
