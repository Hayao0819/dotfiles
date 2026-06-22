# Type idioms

The judgments a linter can't make: when to assert, how to make illegal states
unrepresentable, and which language features have quietly become anti-patterns.

## satisfies vs as vs annotation

Three ways to relate a value to a type — they are not interchangeable.

```ts
type Palette = Record<"red" | "green" | "blue", string | [number, number, number]>;

// Bad: `as` silences the checker. A typo'd key (bleu) is NOT caught, and you can
// assert your way into a lie.
const p1 = { red: "#f00", bleu: "#00f" } as Palette; // typo slips through

// Annotation catches the typo but WIDENS: p2.red is `string | [number,...]`,
// so p2.green[0] no longer type-checks even though you wrote a tuple.
const p2: Palette = { red: "#f00", green: [0, 255, 0], blue: "#00f" };

// Good: `satisfies` validates against Palette AND keeps the precise inferred
// type. Typos are caught; p3.green is still a tuple.
const p3 = {
  red: "#f00",
  green: [0, 255, 0],
  blue: "#00f",
} satisfies Palette;
```

Rule: never reach for `as` to make a type error go away. `as` is justified only
at boundaries you've actually reasoned about — narrowing a parsed `unknown`, a
DOM element cast, an `as const`. Everywhere else, `satisfies` or a proper
annotation.

## Discriminated unions over boolean flags

```ts
// Bad: representable illegal states. What is { isLoading: true, isError: true }?
interface State { isLoading: boolean; isError: boolean; data?: User; error?: Error }

// Good: a discriminant makes illegal combinations impossible to construct.
type State =
  | { status: "loading" }
  | { status: "success"; data: User }
  | { status: "error"; error: Error };

function render(s: State) {
  switch (s.status) {
    case "loading": return spinner();
    case "success": return view(s.data);   // s.data is known to exist here
    case "error":   return oops(s.error);
    default:        return assertNever(s);  // adding a variant becomes a compile error
  }
}
function assertNever(x: never): never {
  throw new Error(`unhandled: ${JSON.stringify(x)}`);
}
```

## Branded / opaque types

Structural typing makes every `string` interchangeable, so `UserId` and
`OrderId` silently swap. Brand them when mixing them up is a real risk:

```ts
declare const brand: unique symbol;
type Brand<T, B> = T & { readonly [brand]: B };

type UserId = Brand<string, "UserId">;
type OrderId = Brand<string, "OrderId">;

function userId(s: string): UserId { return s as UserId; } // the one sanctioned `as`

function getUser(id: UserId) { /* ... */ }
getUser(orderId); // compile error — exactly what you want
```

Reserve brands for IDs, units (`Cents`, `Millis`), and validated strings
(`Email` after zod). Don't brand everything; it adds friction.

## unknown over any

```ts
// Bad: any disables checking and spreads to everything it touches.
function parse(json: string): any { return JSON.parse(json); }

// Good: unknown forces a narrowing step before use.
function parse(json: string): unknown { return JSON.parse(json); }
const data = parse(s);
if (typeof data === "object" && data !== null && "id" in data) { /* ... */ }
// In practice, parse straight into a zod schema — see validation.md.
```

`catch` variables are `unknown` under strict (`useUnknownInCatchVariables`).
Narrow with `instanceof Error` before touching `.message`.

## as const for a single source of truth

```ts
// Derive the type from the data, don't maintain both by hand.
const ROLES = ["admin", "editor", "viewer"] as const;
type Role = (typeof ROLES)[number]; // "admin" | "editor" | "viewer"

// Iterate the values at runtime AND get the union at compile time — one source.
```

## Don't use enum

This is the most-outdated common advice. `enum` (and `const enum`) **emit
runtime JavaScript**, so they are not erasable: they break `isolatedModules`,
error under `--erasableSyntaxOnly` (5.8), and can't be stripped by Node's
type-stripping. Use a const object plus a derived union:

```ts
// Bad
enum Direction { Up, Down, Left, Right }

// Good — erasable, tree-shakeable, same ergonomics.
const Direction = { Up: "up", Down: "down", Left: "left", Right: "right" } as const;
type Direction = (typeof Direction)[keyof typeof Direction];
```

## Recent features worth using

| Feature | Since | Use for |
|---|---|---|
| `satisfies` | 4.9 | the section above |
| `const` type params (`<const T>`) | 5.0 | literal inference without `as const` at call sites |
| Stage-3 decorators `(value, context)` | 5.0 | new decorators; not `experimentalDecorators` |
| `using` / `await using` | 5.2 | deterministic cleanup (`Symbol.dispose`) |
| `NoInfer<T>` | 5.4 | block a type param from inferring off one argument |
| inferred type predicates | 5.5 | `const isNum = (x) => typeof x === "number"` infers `x is number` (but `.filter(Boolean)` still doesn't) |

`experimentalDecorators` + `reflect-metadata` is now legacy — keep it only for
frameworks that still require it (NestJS, TypeORM, Angular DI).
