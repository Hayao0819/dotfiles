---
name: writing-next
description: >-
  Idiomatic, version-current Next.js App Router review and authoring for an
  experienced engineer on Next 16 / React 19. Covers the 'use client'
  module-graph boundary and serializable props, Server Actions treated as public
  unauthenticated endpoints (validate + authN + authZ inside every one), the
  caching model that flipped across Next 14→15→16 (the biggest footgun), async
  Server Component data fetching, waterfalls, streaming, after(), and metadata.
  Use when writing or reviewing Next.js — app/ routes, 'use client'/'use server',
  Server Components, route handlers, next.config, caching, revalidation — or a
  React Server Components question. Defers to writing-ts for pure TypeScript.
---

# Writing Next.js

A reviewer for App Router code on **Next 16 / React 19**. It assumes you know
React and TypeScript (that's **writing-ts**) and focuses on the things unique to
the server/client split, Server Actions, and caching — where the defaults
changed recently and stale advice is actively wrong.

> Compatibility (re-verify on ship): Next.js 16.2 (16.0 GA 2025-10), React 19.2,
> Node ≥ 20.9, TS ≥ 5.1. App Router is the default; Pages Router is supported but
> feature-frozen.

## When to use

- Writing or reviewing anything under `app/`, a route handler, `next.config`, or
  a `'use client'` / `'use server'` module.
- Any question about Server vs Client Components, Server Actions, caching,
  revalidation, streaming, or metadata.

For TypeScript types, zod, tsconfig, and the UI stack (shadcn/ui, Tailwind,
jotai, react-hook-form), defer to **writing-ts**.

## How to read this skill

| Open this | When |
|---|---|
| [reference/server-client.md](reference/server-client.md) | `'use client'` boundary, serializable props, `server-only` |
| [reference/server-actions.md](reference/server-actions.md) | the security model — validate, authN, authZ in every action |
| [reference/caching.md](reference/caching.md) | what changed 14→15→16; Cache Components, `use cache`, revalidation |
| [reference/data-fetching.md](reference/data-fetching.md) | async RSC, waterfalls, streaming, `after()`, metadata |

## What changed — stale advice that is now wrong

The caching and request-API defaults flipped. Flag these aggressively:

| Old (≤ Next 14) belief | Reality now |
|---|---|
| `fetch` is cached by default; `no-store` to opt out | **uncached by default** since 15; opt *in* with `cache: 'force-cache'` or `use cache` |
| `GET` route handlers are cached by default | not cached since 15 |
| navigating back shows cached page content | Client Router Cache `staleTimes` defaults to 0 since 15 |
| `cookies()`/`headers()`/`params` are sync | **async** since 15; sync access **removed** in 16 |
| `import { unstable_after }` | stable `after` from `next/server` since 15.1 |
| `experimental.ppr` / `experimental.dynamicIO` | `ppr` removed; `dynamicIO` → `cacheComponents` |
| `revalidateTag('x')` single arg | needs a `cacheLife` profile in 16 (and `'max'` is lazy SWR); use `updateTag()` for immediate read-your-writes |
| `force-dynamic` keeps fetch caching | sets `no-store` since 15 |
| `middleware.ts` | the file is being renamed `proxy.ts` (Node runtime) in 16, but `middleware.ts` **still works** (deprecated, not removed) and is required for the edge runtime — don't flag working `middleware.ts` as broken |
| `forwardRef` for ref props | `ref` is a normal prop in React 19 |
| `useFormState` | `useActionState` |

## Highest-leverage review checks

- **`'use client'` is a module-graph boundary, not "renders only on the client."**
  A client component still SSRs on first load, and everything it imports ships to
  the browser. Push the directive to the smallest interactive leaf, never the
  layout root. → [server-client.md](reference/server-client.md)
- **Every Server Action is a public, unauthenticated POST endpoint.** Anyone can
  invoke it with any args (the id is encrypted/unguessable, so it's not an
  enumeration sink — but the endpoint is still public). Every action must
  *guarantee* validate-input + authenticate + authorize — inline, or via a shared
  authenticated-client/middleware wrapper. Flag an action reachable with no auth
  path, or one trusting a `userId` arg — not the `safeParse`-vs-`parse` or
  centralized-vs-inline choice. → [server-actions.md](reference/server-actions.md)
- **Caching is opt-in now.** Don't assume a `fetch` is cached. Wrap slow work in
  `<Suspense>` or `use cache`; reach for `cache()` (React, request-scoped) to
  dedup an ORM call hit by both the page and `generateMetadata`.
  → [caching.md](reference/caching.md)
- **Don't `useEffect`+`fetch` for server-owned data.** Fetch in an async Server
  Component (credentials stay on the server) and pass the data — or the promise +
  `use()` — down. → [data-fetching.md](reference/data-fetching.md)
- **Never `NEXT_PUBLIC_`-prefix a secret**, and never read server-only env in a
  client module. Use `import 'server-only'` to make a leak a build error.
- **Use `next/image` and `next/font`**, the `metadata` export / `generateMetadata`
  — not raw `<img>`, Google Fonts `<link>`, or hand-written `<head>`.

## Tooling pass (before commit)

```sh
tsc --noEmit       # the type check (shares writing-ts's setup)
biome check --write .   # or eslint + prettier where the project still uses them
next build         # surfaces RSC/boundary and type errors a unit check misses
pnpm test          # vitest / playwright
```

This inherits **writing-ts**'s toolchain (Biome/typescript-eslint, strict
tsconfig); `next build` is the Next-specific gate that catches server/client
boundary and caching-config errors.

## What this skill is not

- Not React or TypeScript basics — that's **writing-ts**.
- For **security review** of a Server Action or route handler (authz, IDOR,
  injection, SSRF, token handling), that's **auditing-web-app** — this skill is
  the idiom/correctness lens, not the vulnerability lens.
- Not a restatement of the Next.js docs; it's the footguns and the version deltas.
- Prose it helps you write (docs, comments) goes through **natural-writing**.
