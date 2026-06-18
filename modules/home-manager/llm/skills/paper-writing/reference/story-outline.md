# Story and outline (Phase 2)

Build the structure and a first-time-reader story BEFORE any prose. Coarse
granularity — "what goes in each section", not sentences.

## The first-reader story (one paragraph)

Write the paper as a story a competent researcher in the broad field, but NOT in
this subfield, can follow on first read:

> problem → why it matters → what we did → what we found → so what

This is the artifact the context-isolated reviewer (see context-isolation.md)
audits. If you can't write this paragraph, the structure isn't ready.

## Write backwards

Draft the outline in reverse so the motivation matches the payoff (Montagnes et
al.; standard "write the conclusion first" advice):

take-home message → results → methods → discussion → introduction → abstract →
title

This stops the introduction from promising questions the results never answer.

## Context-Content-Conclusion (C-C-C), applied fractally

Mensh & Kording, "Ten Simple Rules for Structuring Papers" (PLoS Comp Biol):
apply C-C-C to the whole paper AND to each section AND each paragraph.

- Context: the first sentence sets up the question.
- Content: the body delivers the new thing.
- Conclusion: the last sentence states what to remember.

The two failure modes to design against: the reader asking "why was I told
that?" (relevance) and "so what?" (impact).

## Question-flow

For each section, state three things in the outline:

1. the question the reader is holding when they arrive,
2. where that question came from (which earlier section raised it) — if it comes
   from nowhere, mark it `unmotivated`,
3. that this section answers it before raising the next question.

A paper reads naturally when every section answers a question the reader now has.

## Story elements (Clemens, LSE)

Introduce tension early ("however", "despite", "but") so the reader feels the
problem before the details. Every element needs a purpose; cut anything that
doesn't advance the story.

## Output

A markdown bullet outline conforming to outline.schema.json: the story
paragraph, then sections, each with heading / beat / reader_question /
question_origin and one line per paragraph (see templates/paragraph-spec.md).
Stop and confirm with the user before drafting.

Sources: Mensh & Kording 2017 (PLoS Comp Biol, PMC5619685); Montagnes et al.
2021 (PMC10077155); Clemens, LSE Impact Blog 2018; Shankar, "Writing in the Age
of LLMs".
