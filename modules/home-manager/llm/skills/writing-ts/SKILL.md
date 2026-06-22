---
name: writing-ts
description: >-
  Idiomatic, version-current TypeScript review and authoring for an experienced
  engineer. Covers type idioms the linter can't catch (satisfies vs as,
  discriminated unions, branded types, unknown over any, const objects over
  enums), boundary validation with zod (parse vs safeParse, infer), the modern
  strict tsconfig baseline, and the 2026 toolchain (TS 6/7 native port, Biome
  vs typescript-eslint, pnpm). Encodes this engineer's actual stack — Next.js,
  shadcn/ui, Tailwind, jotai, react-hook-form, zod, pnpm. Use when writing,
  reviewing, or refactoring TypeScript — .ts/.tsx files, tsconfig, type errors,
  zod schemas — or before committing TS. For Next.js/React App Router specifics,
  see the writing-next skill.
---

# Writing TypeScript

A reviewer for someone who already knows generics, hooks, and async/await. It
spends its budget on what's **non-obvious**, what **changed recently**, and what
a **linter won't catch**. Anything `tsc --strict`, Biome, or typescript-eslint
already enforces is out of scope — run the tool.

> Compatibility (re-verify on ship; these move): TypeScript 6.0 (the last
> JS-based `tsc`, GA 2026-03); TypeScript 7.0 — the native Go port, ~10× faster,
> RC 2026-06 — semantics identical to 6.0. zod 4, ESLint 10 (flat-only),
> typescript-eslint 8, Biome 2, pnpm 11. Note: most of the engineer's repos still
> pin **TS ^5 / 5.8** (only hayao0819.com is on 6.0), so 6.0's default flips
> (target es2025, `types: []`, dropped `moduleResolution node`) are a migration to
> confront, not the current state of most code.

## When to use

- Reviewing or writing any `.ts`/`.tsx`, or editing `tsconfig.json`.
- Deciding how to model a type, validate a boundary, or set strictness.
- Picking or using the stack (UI, state, forms, validation) — see
  [reference/stack.md](reference/stack.md) for the established choices.
- Before committing TS: run the tooling pass at the bottom.

Next.js, React Server Components, Server Actions, and caching live in
**writing-next** — defer there for anything App-Router-shaped.

## How to read this skill

| Open this | When |
|---|---|
| [reference/type-idioms.md](reference/type-idioms.md) | `satisfies`/`as`, unions, branded types, `unknown`, enums, `as const` |
| [reference/validation.md](reference/validation.md) | zod at boundaries, parse vs safeParse, infer, valibot/arktype |
| [reference/tsconfig-tooling.md](reference/tsconfig-tooling.md) | strict flags, Biome vs ESLint, the native port, pnpm |
| [reference/stack.md](reference/stack.md) | the de-facto stack + the categories that are still a choice |

## What changed — stop writing the old form

| Old form | Modern form | Note |
|---|---|---|
| `as` to fix a type error you don't understand | `satisfies` (validate, keep narrow type) | `as` silences typos; `satisfies` catches them |
| `enum Direction { Up, Down }` | `const Direction = {...} as const` + union type | enums emit runtime JS, aren't erasable, break `--erasableSyntaxOnly` and Node type-stripping |
| `const enum` "zero-cost" | const object + union | breaks `isolatedModules`; advice is now harmful |
| `any` for "I don't know the type" | `unknown` + narrowing | `any` is infectious and disables checking |
| hand-rolled `NoInfer` helper | `NoInfer<T>` | built in (5.4) |
| `forwardRef` for a ref prop | `ref` as a normal prop | React 19 |
| `importsNotUsedAsValues` / `preserveValueImports` | `verbatimModuleSyntax` + `import type` | the old flags are deprecated |
| parallel hand-written interface + validator | `z.infer<typeof Schema>` | schema is the single source of truth |
| `eslintrc` config | ESLint flat config (`eslint.config.ts`) | v10 removed eslintrc |

## Highest-leverage review checks

- **Reach for `satisfies`, not `as`.** `as` is an assertion that silences the
  checker (and typos); `satisfies` validates the value against a type while
  keeping its precise inferred shape. `as` is justified only at genuine
  boundaries you've reasoned about (a parsed `unknown`, a DOM cast).
  → [type-idioms.md](reference/type-idioms.md)
- **Model illegal states out of existence with discriminated unions**, not
  parallel booleans. `isLoading && isError` shouldn't be representable. Add an
  `assertNever` default so a new variant is a compile error.
- **Parse at every untyped boundary** (request body, `process.env`,
  `JSON.parse`, message payloads) with zod; derive the type with `z.infer`.
  Never trust a hand-written `interface` over the wire. → [validation.md](reference/validation.md)
- **`unknown` over `any`**, always — including `catch` vars. An `any` in
  business logic is a hole in the type system, not a shortcut.
- **`strict` is the floor.** Add `noUncheckedIndexedAccess` and
  `exactOptionalPropertyTypes` — the bugs they catch (assuming `arr[i]` exists,
  conflating absent vs `undefined`) are exactly the ones that reach production.
  → [tsconfig-tooling.md](reference/tsconfig-tooling.md)
- **Don't introduce a library where the stack already has one.** Validation is
  zod, forms are react-hook-form, client state is jotai, UI is shadcn/ui. For
  the categories that are genuinely a choice, see [stack.md](reference/stack.md).

## Tooling pass (before commit)

```sh
tsc --noEmit          # the type check is the real gate (run tsgo when on the native port)
biome check --write . # format + fast lint (the recent projects' choice)
# or, where the project still uses them:
eslint . && prettier --write .
pnpm test             # vitest
```

Type-checked lint rules (`no-floating-promises`, `no-misused-promises`) still
need typescript-eslint — Biome's type-aware coverage is early. A starting
`tsconfig.json` is in [assets/tsconfig.reference.json](assets/tsconfig.reference.json)
and a Biome config in [assets/biome.reference.json](assets/biome.reference.json);
adopt per repo, don't impose where one exists.

## What this skill is not

- Not a TypeScript tutorial and not a restatement of `tsc`, Biome, or
  typescript-eslint. If a tool enforces it, route to the tool.
- Not Next.js/React guidance — that's **writing-next**.
- Prose this skill helps you write (JSDoc, comments, README) still goes through
  **natural-writing**; comments explain *why*, not *what*.
