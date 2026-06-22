# Data fetching, streaming, metadata

## Fetch in async Server Components

The default data path is an async Server Component reading directly from the
source. Credentials and queries never reach the client:

```tsx
// page.tsx — a Server Component. No client fetch library, no exposed endpoint.
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;          // params is async since 15
  const post = await db.post.find(id);  // or fetch(); runs on the server
  return <Article post={post} />;
}
```

```tsx
// Bad: useEffect + fetch for server-owned data — a client round-trip, a
// waterfall, and you had to expose an endpoint to serve it.
"use client";
useEffect(() => { fetch("/api/post").then(setPost); }, []);
```

When a client component genuinely needs the data, start the fetch on the server
and pass the **promise** down, resolving it with `use()`:

```tsx
// Server Component
const postPromise = db.post.find(id); // don't await
return <Comments postPromise={postPromise} />;

// Client Component
"use client";
import { use } from "react";
function Comments({ postPromise }) {
  const post = use(postPromise); // suspends here, not at the page root
}
```

## Avoid waterfalls

```ts
// Bad: sequential awaits — each waits for the previous for no reason.
const user = await getUser(id);
const posts = await getPosts(id);

// Good: start independent work together.
const [user, posts] = await Promise.all([getUser(id), getPosts(id)]);
// Promise.allSettled if you want to tolerate one failing.
```

Genuinely dependent fetches go behind their own `<Suspense>` so the rest of the
page streams while they resolve.

## Streaming

- `loading.tsx` streams a fallback for the whole route segment.
- `<Suspense>` streams granular parts — wrap the slow component, render the shell
  immediately.
- Remember the layout gotcha from [caching.md](caching.md): a layout reading
  runtime data blocks navigation rather than using `loading.js`.

## after()

Run work after the response finishes streaming (logging, analytics) without
delaying the user or making the route dynamic:

```ts
import { after } from "next/server"; // stable since 15.1 (not unstable_after)

export async function POST(req: Request) {
  const data = await handle(req);
  after(() => log.event("handled", { size: data.length })); // runs post-response
  return Response.json(data);
}
```

Caveat: in a **Server Component** you can't call `cookies()`/`headers()` *inside*
the `after` callback — read them first and close over the value. (Route handlers
and server functions may call them inside.)

## Metadata, images, fonts

- Export `metadata` or `generateMetadata` (Server Components only) — never
  hand-write `<head>`; the metadata API merges, dedups, and streams.
- `next/image` gives automatic dimensions and CLS avoidance — not raw `<img>`.
  Real 16 changes: `qualities` now required (default `[75]`), `minimumCacheTTL`
  60s→4h, value `16` dropped from default `imageSizes`, and `priority` deprecated
  in favor of `preload`. (`images.domains` → `remotePatterns` is older — deprecated
  since Next **14**, not a 16 change.)
- `next/font` self-hosts the font (no Google Fonts `<link>` — that's a CLS and
  privacy regression).
