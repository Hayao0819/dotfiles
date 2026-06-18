# Paragraph spec

One line per paragraph, written BEFORE any prose. The point is to fix "what
information goes here" so drafting can't drift into LLM filler or invented
content. Keep it coarse; this is a plan, not the paragraph.

Format per line:

```
[section] / [paragraph-id]: MESSAGE — support: [citation-ids | data] (beat: X)
```

- **MESSAGE**: the single claim a reader could disagree with. Not a topic
  ("about caching") but an assertion ("the cache invalidation cost dominates
  above 10k keys").
- **support**: which pooled citation ids (citation.schema.json) or which
  figure/number/experiment backs it. If nothing backs it yet, write
  `[MATERIAL GAP]` — do not plan to fill it from memory.
- **beat**: which story beat this advances (ties back to the first-reader story).
- Mark synthesis-heavy paragraphs (related work, discussion) `human:` — those
  the human drafts and the skill only comments on.

Example:

```
intro / p3: existing runtime-measurement registers are host-controlled, so a
  compromised host can forge them — support: [doi-a1b2, arxiv-c3d4] (beat: gap)
methods / p2: we hook IMA's measurement function and mirror each event into an
  RTMR extend — support: data:fig2 (beat: how)
related / p1: TPM-based attestation and our RTMR approach diverge on the
  measurement start point — support: [dblp-e5f6, doi-7890] human: (beat: contrast)
discussion / p4: the IMA+TPM vs IMA+RTMR discrepancy is [MATERIAL GAP] — need
  a source or our own measurement (beat: limitation)
```
