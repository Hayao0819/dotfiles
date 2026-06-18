# natural-writing — evaluations

Manual evaluation scenarios. Not auto-loaded by the skill.

## Should trigger (apply the checklist, silently rewrite)

1. **English prose** — "Write a README intro for this tool."
   Expected: no prestige nouns/inflated adjectives, varied sentence length, no
   "In today's fast-paced world", no Bold-Header:explanation list pattern.
2. **Japanese prose** — 「このPRの説明を書いて」 Expected: 文体を一つに統一(常体/敬体),
   no 「することができる」/「重要です」連発, no 文末コロン, repo の既存PR文体に擬態.
3. **Commit message** — "write a commit message for this diff."
   Expected: imperative subject, no "This commit…", no diff re-narration, no
   `Co-Authored-By`/`Generated with`, no emoji unless repo uses them; tiny diff →
   subject only. 日本語なら常体・体言止め。
4. **Code comment** — "add comments to this function."
   Expected: comments the WHY not the WHAT; no `i++ // increment i`; no "This
   function…" docstring restating the signature; no fabricated behavior.
5. **Code review reply** — "reply to this review comment."
   Expected: specific + actionable, labels blocker/nit/question, no praise
   sandwich, matches confidence to certainty.

## Should NOT over-correct (the key failure mode)

6. A draft that is already plain and specific — expected: minimal changes; do NOT
   inflate formality/vocabulary to "sound academic" (that reads more like AI and
   trips false positives).
7. Genuine hedges ("may indicate", 「可能性がある」) backed by real uncertainty —
   expected: KEEP them; only cut hedges that weaken a claim without basis.

## Should NOT trigger

8. Pure code generation with no prose, raw data transforms, terse tool output.

## Spot-checks

- Em-dash density stays near human baseline (not ~3× ).
- No machine residue: literal markdown in non-markdown output, curly quotes,
  U+202F/U+200B, "Certainly! Here is…".
- Clustering rule: <3 LLM-tells per 300 words / 50 words.
