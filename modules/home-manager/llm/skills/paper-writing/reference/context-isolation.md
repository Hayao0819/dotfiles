# Context isolation: the first-reader review (Phase 2) and clarity critics (Phase 6)

## Why isolate context

When an agent shares the author's full context, it stops seeing undefined terms,
coined jargon, and leaps in logic — the curse of knowledge. Reviewing in a fresh
session with no production history catches more substantive errors than
same-session self-review, and the gain comes from context separation itself, not
from "reviewing twice" (Cross-Context Review, arXiv 2603.12123; also the
curse-of-knowledge-in-LLM-judges result, arXiv 2509.03419). Anthropic's own
guidance: run sub-agents in clean context windows and return only a distilled
summary.

So: spawn the reviewer as a fresh agent (Task / Agent tool) that does NOT receive
this conversation. Give it ONLY the outline (Phase 2) or the drafted section
(Phase 6). Tell the user before launching it.

## Pattern A — first-reader / outline audit (Phase 2)

Give the agent only the outline + story. Prompt:

> You have never seen this project before. You are a competent researcher in
> [broad field] but you do NOT work in [specific subfield]. Read this outline for
> the first time. For each section in order:
> 1. State the single question you are holding as you arrive at this section.
> 2. Say where that question came from (which earlier section). If it appears
>    from nowhere, write "unmotivated".
> 3. Does this section answer that question before raising a new one? Quote the
>    line that answers it, or write "UNANSWERED".
> 4. List every term, acronym, or coined name used here that was not defined
>    earlier; for each, say whether an outsider could infer it.
> Finally: restate the whole paper's argument in 3 sentences, and mark any step
> where you had to guess.

## Pattern B — explain-back / comprehension test (Phase 6)

Fresh agent, drafted section only (Explain-Query-Test, arXiv 2501.11721):

> 1. Summarize what this section claims, in plain language, for a smart colleague
>    from a different field.
> 2. Generate 5 questions a first-time reader needs answered to accept the main
>    claim.
> 3. Answer each using ONLY the text provided. If the text doesn't answer it,
>    write "NOT IN TEXT".

Every "NOT IN TEXT" is a clarity gap.

## Pattern C — jargon / curse-of-knowledge critic

> List every term that assumes subfield knowledge, every coined/in-project name,
> and every abbreviation. For each: (defined in text? yes/no) and (inferable by
> an outsider? yes/no). Output only the rows where either answer is "no".

## HITL checkpoint placement

Stop and show the human the distilled flags + one decision — never the full agent
transcript. Cheapest, highest-value stop is right after the Phase 2 outline
review. Then after the intro/motivation draft, then after each major section. If
a drafting↔critique loop doesn't converge in N rounds, escalate to the human
instead of thrashing.

Keep the human as the final arbiter on accept/reject judgments — the
LLM-as-reviewer literature documents reviewer bias and prompt-injection risk.
