# Server Actions

The single most important Next.js security fact: **a Server Action compiles to a
public, unauthenticated POST endpoint.** Its id is a hash of the source location,
discoverable in the client bundle. Anyone can POST to it with any arguments. The
`'use server'` directive exports an HTTP endpoint, not a private function.

So a Server Action is exactly as exposed as a hand-written API route — and TS
types are erased at runtime, guaranteeing nothing. Treat every action as a
boundary.

## The mandatory three checks, guaranteed for every action

Every action must (1) **validate input**, (2) **authenticate**, (3) **authorize**
the specific resource. The checks must be *guaranteed* — either inline, or via a
shared authenticated-client / middleware wrapper that every action goes through
(the engineer's house style: a `createAuthenticatedClient()` that centralizes
auth, plus `schema.safeParse(...)` returning a structured `ActionResult` rather
than throwing). What to flag is an action **reachable with no auth path at all**,
or one that trusts a `userId` arg instead of the session — not the choice of
`safeParse`-over-`parse` or centralized-over-inline auth.

```ts
// Inline form (one accepted shape):
"use server";
import { z } from "zod";
import { cookies } from "next/headers";

const Input = z.object({ postId: z.uuid(), title: z.string().min(1).max(200) });

export async function updatePost(formData: FormData) {
  // 1. VALIDATE — types are erased at runtime. safeParse + ActionResult is the
  //    house style; .parse (throws) is fine where a throw is correct.
  const parsed = Input.safeParse(Object.fromEntries(formData));
  if (!parsed.success) return { ok: false, errors: z.treeifyError(parsed.error) };

  // 2. AUTHENTICATE — from the session, never from an arg. Inline here, or via a
  //    shared createAuthenticatedClient()/middleware the action goes through.
  const session = await getSession(await cookies());
  if (!session) return { ok: false, error: "unauthorized" };

  // 3. AUTHORIZE — this user may touch this resource (prevents IDOR).
  const post = await db.post.find(parsed.data.postId);
  if (post.authorId !== session.userId) return { ok: false, error: "forbidden" };

  await db.post.update(parsed.data.postId, { title: parsed.data.title });
  updateTag(`post:${parsed.data.postId}`); // read-your-writes; see caching.md
  return { ok: true };
}
```

Skipping any one of these is the classic Server Action vulnerability. The most
common in review: trusting a `userId` passed as an argument instead of reading it
from the session. A shared wrapper that enforces auth for every action satisfies
checks 2–3 centrally — don't flag an action for not re-reading `cookies()` inline
when a wrapper already guarantees it.

## What the framework gives you (and doesn't)

- **Does:** CSRF protection (POST-only + Origin/Host check), and encrypts
  closure-captured variables with a per-build key.
- **Does not:** authenticate, authorize, validate input, or encrypt `.bind`
  arguments. `action.bind(null, secret)` arguments are **not** encrypted — don't
  bind secrets.

## Progressive enhancement

```tsx
// Works without JS: <form action={fn}>. With JS, useActionState wires state.
function EditForm({ action }: { action: (s: State, fd: FormData) => Promise<State> }) {
  const [state, formAction, pending] = useActionState(action, initialState);
  return (
    <form action={formAction}>
      <input name="title" />
      <button disabled={pending}>Save</button>
      {state.error && <p>{state.error}</p>}
    </form>
  );
}
```

`next-safe-action` is the community wrapper (middleware chains validate → authN →
authZ, Standard Schema). It's ergonomic but **not a security substitute** — the
three checks still have to happen.

## Server Action vs Route Handler

| Use a Server Action | Use a Route Handler |
|---|---|
| mutations from your own frontend | webhooks, public/shared APIs |
| progressive-enhancement forms | custom HTTP verbs, streaming responses |
| read-your-writes (`updateTag`/`refresh`) | third-party callers |

For a pure internal **read**, you often need neither — fetch directly in an async
Server Component. Route handlers carry their own CSRF responsibility; Server
Actions get it for free.
