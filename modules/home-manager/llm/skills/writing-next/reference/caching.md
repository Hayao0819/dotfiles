# Caching

This is the biggest footgun in modern Next.js because the defaults **inverted**
between 14 and 15, and 16 reorganized the whole model. Most stale advice on the
internet is about Next 14. Get the version right before trusting any caching
claim.

## The flip: 14 → 15

| Cache | Next 14 | Next 15+ | Opt back in |
|---|---|---|---|
| `fetch()` | cached (`force-cache`) | **uncached** (`auto no cache`) | `cache: 'force-cache'` or `next: { revalidate }` |
| `GET` route handler | cached | **uncached** | `export const dynamic = 'force-static'` |
| Client Router Cache (page segments) | cached | **`staleTimes` default 0** | `experimental.staleTimes.dynamic` |
| Request memoization (per render) | on | on | — (dedups identical fetches in one render) |

The Next 15 release said it plainly: *"`fetch` requests, `GET` Route Handlers, and
client navigations are no longer cached by default."* Precise wording: the fetch
default is `auto no cache` — uncached at runtime, still prerendered at build for a
static route unless it reads request-time APIs. It is not literally `no-store`.

```ts
// Bad (Next 14 muscle memory): assuming this is cached and adding no-store "to be safe".
const res = await fetch(url, { cache: "no-store" }); // redundant — already uncached in 15+

// Good: be explicit about the intent you actually want.
const res = await fetch(url, { next: { revalidate: 3600 } }); // cache for an hour
```

## The Next 16 model: Cache Components

16 makes caching explicit and opt-in via **Cache Components** (this is the renamed
`experimental.dynamicIO`; the old `experimental.ppr` flag is removed, PPR folded
in):

- Enable with `cacheComponents: true` in `next.config`. It is **not on by
  default**.
- The **`use cache`** directive marks a function/component/file as cacheable
  (introduced experimental in 15, enabled via Cache Components in 16).
  `cacheLife(profile)` and `cacheTag(tag)` are now stable (drop the `unstable_`).
- With Cache Components on, any non-sync data access *outside* a `<Suspense>` or a
  `use cache` scope is a build error — the model forces you to declare what's
  cached and what streams.
- Runtime APIs (`cookies()`, `headers()`) cannot be read inside a `use cache`
  scope — pass their values in as arguments.

```ts
// A cached data function with a tag and a lifetime.
async function getPost(id: string) {
  "use cache";
  cacheTag(`post:${id}`);
  cacheLife("hours");
  return db.post.find(id);
}
```

## Revalidation changed in 16

```ts
// The single-arg form is deprecated in 16.
revalidateTag("posts");

// Two-arg takes a cacheLife profile — but note 'max' is LAZY stale-while-
// revalidate (refreshed on the next visit), NOT an immediate expire.
revalidateTag("posts", "max");

// For immediate read-your-writes in a Server Action, use updateTag (immediate):
updateTag(`post:${id}`); // refresh this tag and re-render with fresh data now
refresh();               // re-render the current route's uncached content
// For a webhook/route handler needing instant expiry:
revalidateTag("posts", { expire: 0 });
```

`unstable_cache` is still valid only on the **previous** (non-Cache-Components)
path. On 16 with Cache Components, use `use cache` + `cacheLife` instead.

## Request-scoped dedup with React `cache()`

Different from cross-request caching — `cache()` dedups a non-`fetch` data source
(an ORM call) across call sites *within one request*:

```ts
import { cache } from "react";

// Called by both the page and generateMetadata — runs the query once per request.
export const getUser = cache(async (id: string) => db.user.find(id));
```

This is the canonical fix for "my page and my metadata both hit the same row."
It's deduplication, not a persistent cache.

## Layout caching gotcha (16)

A **layout** that reads runtime data (`cookies()`, an uncached fetch) does **not**
fall back to the same segment's `loading.js` — it blocks navigation instead. Wrap
the runtime access in `<Suspense>`, or move it down into `page.js`.
