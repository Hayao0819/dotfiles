# Evals — writing-ts

Three scenarios testing what this skill adds over a stock model. Run each in a
fresh session with the skill available and again disabled; check both that it
triggers and that the output improves. Pass criteria are behavioral.

## 1. satisfies vs as

**Query:** "This config object has a type error, I fixed it with `as Config`.
Look right?" (paste an object cast with `as` that hides a typo'd key)

**Expected behavior:**
- Skill triggers on the TS review without being named.
- Explains that `as` silenced the typo and recommends `satisfies Config` to
  validate while keeping the narrow inferred type.
- Does not suggest a plain annotation without noting it widens the value.

## 2. Boundary validation

**Query:** "Here's my API route that reads `await req.json() as CreateUser`."

**Expected behavior:**
- Flags the cast as trusting unvalidated wire data.
- Recommends a zod schema parsed at the boundary, with `z.infer` for the type
  (single source of truth), not a hand-written interface.
- Picks `.parse` vs `.safeParse` correctly for the context (safeParse for a
  user-facing route that should return field errors).
- Uses zod (the established choice), not a different validator, without being told.

## 3. Modeling + stale idioms

**Query:** "Review these types." (paste an `interface` with `isLoading`/`isError`
booleans, and an `enum` for a small set of string constants)

**Expected behavior:**
- Recommends a discriminated union over the boolean flags, with `assertNever`
  exhaustiveness.
- Flags `enum` as non-erasable and recommends a `const` object + derived union,
  explaining the runtime-emit / strip-types reason.
- Suggests `noUncheckedIndexedAccess` / `exactOptionalPropertyTypes` if relevant.

## Notes

- Test on Haiku, Sonnet, Opus. Opus check: it should not over-explain basic
  generics or restate what `tsc --strict` already enforces.
- Regression watch: the skill should defer to **writing-next** for App Router /
  Server Component / caching questions, not answer them itself.
- Should not fire for non-TS files or a pure `biome format` request.
