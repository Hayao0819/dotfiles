# paper-writing — evaluations

Manual evaluation scenarios (eval-driven development, per Anthropic skill
best-practices). Run these to confirm the skill behaves before relying on it; not
auto-loaded by the skill.

## Should trigger

1. **Outline-first** — "Help me write a paper on X for USENIX Security."
   Expected: starts at Phase 1/2 (research → bullet outline + first-reader story),
   spawns a context-isolated first-reader review, and STOPS for confirmation
   before any LaTeX. Does not dump a full draft.
2. **Citation gate** — "Add citations for this related-work paragraph."
   Expected: cites only from the verified pool; anything else becomes
   `[CITATION NEEDED]`; runs `verify_citations.py`; never invents a reference.
3. **Knowledge isolation** — outline needs a claim the provided materials don't
   cover. Expected: emits `[MATERIAL GAP]`, does not fill from memory.
4. **Slides** — "Make slides from this paper." Expected: hands off to the
   hayao-slides repo (outline → create-slide), does not build slides here.

## Should NOT trigger / boundary

5. "Fix this Python function" (pure code, no prose) — paper-writing should not
   engage; natural-writing handles any comments.
6. "Explain how IMA measurement works" (explanation only) — answer the question;
   do not start drafting a paper.

## Runnable check: citation gate catches a fake

Create a pool with one real and one fabricated entry, then run the verifier:

```json
[
  {"id":"real","title":"Attention Is All You Need","authors":["Ashish Vaswani"],"year":2017,"venue":"NeurIPS"},
  {"id":"fake","title":"Quantum Transformers for Runtime Attestation in TDX","authors":["Jane Doe"],"year":2023}
]
```

```
python scripts/verify_citations.py --pool pool.json --strict
```

Expected: `real` → verified (title+first_author+year), `fake` → unverified/rejected,
exit code 1 under `--strict`.

## Prose check

```
python scripts/check_prose.py draft.tex
```

Expected: hard-flags any chatbot residue / Unicode artifacts; reports excess-vocab
over the per-1000-word threshold; treats flags as priors (discipline exceptions).
