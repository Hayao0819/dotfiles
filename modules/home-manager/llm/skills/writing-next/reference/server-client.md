# Server / client boundary

## `'use client'` is a module-graph boundary

The most common misconception: `'use client'` does *not* mean "renders only in
the browser." It marks the point where the module graph crosses to the client.
The component still **server-renders on first load**, and everything imported
into a `'use client'` module — and its imports — is shipped to the browser.

```tsx
// Bad: directive at the layout root drags the entire subtree to the client and
// breaks any server-only code it imports.
"use client";
export default function RootLayout({ children }) { ... }

// Good: the page stays a Server Component; only the interactive leaf opts in.
// page.tsx (Server Component) renders <LikeButton/> (client).
"use client";
export function LikeButton({ initial }: { initial: number }) {
  const [n, setN] = useState(initial);
  return <button onClick={() => setN((x) => x + 1)}>{n}</button>;
}
```

Two consequences reviewers check:
- **Guard browser APIs.** A client component runs on the server during SSR, so
  `window`/`document`/`localStorage` at module or render top-level crashes. Read
  them in `useEffect` or behind a mounted check.
- **Keep the directive low.** Server Components can render Client Components, and
  can pass Server Components to them as `children`/props — so you can keep an
  interactive shell around server-rendered content without making it all client.

## Serializable props (Server → Client)

Props crossing from a Server Component into a Client Component must be
serializable. The exact allowed set:

- **Allowed:** primitives, `Date`, plain objects/arrays, `Map`/`Set`/`TypedArray`/
  `ArrayBuffer`, `Promise` (unwrap on the client with `use()`), JSX, registered
  symbols (`Symbol.for`), and **Server Actions** (`'use server'` functions).
- **Not allowed:** plain functions / event handlers, class instances,
  null-prototype objects, non-global symbols.
- **Not a prop, despite the name:** `FormData` is what React passes *into* a
  Server Action from `<form action={fn}>` — it is not in React's Server→Client
  serializable-prop set, so don't pass a `FormData` object down as a prop.

```tsx
// Bad: passing a function (not a Server Action) across the boundary.
<Client onSave={(x) => db.save(x)} />        // serialization error

// Good: pass a plain DTO down, and a Server Action for the mutation.
<Client user={userDTO} saveAction={saveUser} /> // saveUser is 'use server'
```

Passing a `Promise` down and resolving it with `use()` in the client lets you
start a fetch on the server and stream it in without blocking render — see
[data-fetching.md](data-fetching.md).

## Keep secrets on the server

```ts
// lib/secrets.ts
import "server-only"; // build error if this module is ever imported by client code

export const apiKey = process.env.API_KEY; // never NEXT_PUBLIC_*
```

- `NEXT_PUBLIC_*` is inlined into the client bundle — only for genuinely public
  values. A secret with that prefix is a leak.
- Reading a non-public env var in a client component yields `undefined` at
  runtime; read it on the server and pass the result as a prop.
- `import 'server-only'` (and its sibling `import 'client-only'`) turn a wrong-side
  import into a compile-time failure — use them on modules that touch secrets or
  server resources.

## React 19 notes that matter here

- `ref` is a normal prop — drop `forwardRef` in new components.
- `useActionState` replaces `useFormState`; `useFormStatus` reads pending state of
  the enclosing `<form>`; `useOptimistic` for optimistic UI.
- `use(promise)` suspends until resolution and may be called conditionally — but
  don't *create* the promise during render (create it on the server, pass it in).
