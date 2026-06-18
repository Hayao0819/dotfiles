# Argumentation rigor (Phase 6 logic dimension)

The logic/argument review. Adapted from k16shikano's 日本語技術文書の文章規範
(https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d) and the
paper-structuring literature. Applies to English and Japanese.

## Paragraph = one step of the argument

- One topic per paragraph. The opening sentence states what the paragraph is
  about; the reader must be able to follow the logic paragraph by paragraph.
- Mark the logical relation to the previous paragraph with a connective only when
  it marks a real turn (because / therefore / however / 〜ため、〜が).
- Argue in one direction. Handle objections BEFORE stating the conclusion, then
  state the conclusion once. Don't conclude, then rebut, then re-conclude.
- Negate the reader's likely misreading before giving the real reason
  ("the reason is not X; it is Y"). When you deny something, write the exact
  proposition being denied in quotes — not a vague "this doesn't solve
  everything".
- Forward references ("we address this in §5") go at a paragraph/section end, not
  mid-argument, and must actually be paid off.

## Logical rigor

- Don't mechanically turn hedges into assertions. Keep genuine uncertainty
  (unconfirmed possibility, inference from logs, a reader's likely doubt,
  counterfactual). Convert to a flat assertion only when an in-text basis makes
  the proposition certain.
- Don't lump distinct things as "the same" — separate decisions, separate causes,
  different kinds of problem stay separated.
- Don't reduce a multi-factor event to a single cause. If an example contains
  several problems, separate them and map which tool addresses which.
- A causal claim states the mechanism in one sentence ("A causes B" is not
  enough — say why). 
- Detection/guarantees are stated conditionally ("tends to", "holds only when"),
  never as unconditional "always".
- Verify the examples actually support the claim's full scope; if they support
  only part, narrow the claim to fit.
- Never end on a concession ("that said, …"). After a concession, advance the
  argument.
- Define a section's central term before using it.

## Reader burden

- Don't introduce proper names (filenames, function names) the reader won't need
  later; use a general term. Gloss an ambiguous abstraction in place rather than
  forcing a re-read. Pre-announce why a new example is needed. Omit only detail
  irrelevant to the section's question.

## Headings and honesty

- Headings specify the section's content/question, not bare procedure, and don't
  spoil the conclusion.
- If an example looks artificial, acknowledge it and ground it in common
  knowledge — don't assert "this is realistic" on the author's authority. Never
  present unconfirmed content as confirmed.
