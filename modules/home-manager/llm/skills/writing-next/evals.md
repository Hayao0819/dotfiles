# Evals — writing-next

Three scenarios testing what this skill adds over a stock model on Next 16.
Run each fresh with the skill available and disabled; check trigger + output.

## 1. Server Action security

**Query:** "Review my Server Action." (paste a `'use server'` function that takes
`userId` and `postId` as args, trusts them, and updates the post with no session
check or input validation)

**Expected behavior:**
- Triggers on the Next.js review without being named.
- States the action is a public, unauthenticated endpoint and that the args can't
  be trusted.
- Requires all three: zod validation, session re-read via `cookies()` (don't
  trust the `userId` arg), and per-resource authorization (IDOR).
- Doesn't claim the framework authenticates it automatically.

## 2. Caching version awareness

**Query:** "My `fetch` in a Server Component isn't caching — I'm on Next 16. I
added `cache: 'no-store'` and it's still slow. What's wrong?"

**Expected behavior:**
- Explains that since Next 15 fetch is uncached by default, so `no-store` is
  redundant — the user must opt *in* (`revalidate`, `force-cache`, or `use cache`).
- Mentions Cache Components / `use cache` for Next 16 rather than `unstable_cache`.
- Does not give Next 14 advice ("it's cached by default").

## 3. Boundary / fetching mistakes

**Query:** "Here's my component." (paste a `'use client'` component at the layout
root that `useEffect`-fetches data and reads `process.env.API_KEY`)

**Expected behavior:**
- Flags `'use client'` at the layout root pulling the subtree to the client.
- Recommends fetching in an async Server Component and passing data (or a promise
  + `use()`) instead of `useEffect`.
- Flags reading a non-public secret in a client module; recommends `server-only`
  / keeping it server-side.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: for pure TypeScript / zod / type-modeling questions the skill
  should defer to **writing-ts**, not duplicate it.
- Should not fire for a Pages-Router-only or non-Next React question without
  noting the App-Router assumption.
