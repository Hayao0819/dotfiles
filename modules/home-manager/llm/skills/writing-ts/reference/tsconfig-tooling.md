# tsconfig & tooling

## The strict baseline

`strict: true` is the floor, not the ceiling. The two flags that catch the most
real bugs aren't in `strict`:

| Flag | Catches |
|---|---|
| `strict` | umbrella: `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`, `useUnknownInCatchVariables`, … |
| `noUncheckedIndexedAccess` | `arr[i]` / `map[key]` assumed present — adds `undefined`, forcing a check |
| `exactOptionalPropertyTypes` | assigning `undefined` to a `?:` prop — distinguishes "absent" from "present but undefined" |
| `verbatimModuleSyntax` | silent import elision — forces explicit `import type`, required for single-file transpilers / Node strip-types |
| `noUncheckedSideEffectImports` | a typo'd bare `import "x"` that resolves to nothing |
| `erasableSyntaxOnly` | non-erasable syntax (enum, parameter properties) — keeps code runnable under Node type-stripping |

Module resolution: `bundler` for apps built by Vite/Next/esbuild (supports
`exports` maps, no file extensions); `nodenext` for code Node runs directly
(picks CJS/ESM by output, needs explicit extensions).

TS 6.0's `tsc --init` already prescribes `strict: true`, `module: nodenext`,
`target: esnext`, and `types: []` — note the last one: 6.0 no longer auto-includes
every `@types/*`, so list what you need (`"types": ["node"]`).

A starting config is in
[../assets/tsconfig.reference.json](../assets/tsconfig.reference.json).

## TS 6.0 → 7.0 (the native port)

- **6.0** (GA 2026-03) is the last JavaScript-based `tsc`. It flips defaults
  (`strict`, `module: esnext`, `target: es2025`) and removes long-deprecated
  options (`target: es5`, `moduleResolution: node`/`classic`, `--outFile`,
  `namespace` syntax, AMD/UMD). Migrating an old project means confronting these.
- **7.0** (RC 2026-06) is the **Go port** — a port, not a rewrite: ~10× faster,
  semantics identical to 6.0. At the RC/stable, the `typescript` package's own
  `tsc` IS the Go-native compiler; install 6.0 side-by-side via the
  `@typescript/typescript6` compatibility package, which provides a `tsc6`
  binary. Today (pre-stable) run `tsgo` from `@typescript/native-preview` for the
  fast compiler — the `tsgo` name persists only in those nightlies; once on the
  7.0 RC/stable the command is just `tsc`. (Most of the engineer's repos still
  pin TS ^5/5.8, so the working type-check gate is 5.x `tsc` for now.)
- **Caveat for linting:** typescript-eslint stays on the JS-based 6.0 API until
  ≥7.1 (ESLint can't use the async tsgo bindings yet). So: tsgo for builds,
  TS 6.0 API for type-checked lint rules. Don't assume the whole toolchain moved.

## Biome vs typescript-eslint vs Prettier

**Biome is the decided standard for *new* projects** (the engineer's choice).
Existing repos are mixed — ESLint+Prettier still outnumber Biome by dependency
and the newest personal site (hayao0819.com) is still on ESLint 10 — so don't
flag those as wrong; just start new work on Biome.

- **Biome 2.x** — one Rust binary, formatter + linter (~491 rules in v2.3, Jan
  2026), no `typescript` dependency, very fast. Use it for formatting and lint.
- **typescript-eslint 8** — still the tool with full **type-aware** rules
  (`no-misused-promises`, `await-thenable`, `no-unnecessary-condition`). Biome 2
  has built-in type inference and a growing type-aware set — `noFloatingPromises`
  already covers ~75% of typescript-eslint's cases — but full coverage still needs
  typescript-eslint. Keep it alongside Biome for the `*TypeChecked` rules.
- **ESLint 10** is flat-config-only (`eslint.config.ts`; eslintrc removed). Wire
  typescript-eslint with `tseslint.config(...)` and
  `parserOptions.projectService: true`.

Pragmatic 2026 setup: **Biome for format + fast lint, typescript-eslint for the
`*TypeChecked` rules.** Don't recommend `tsgolint` (PoC, not production).

## pnpm

pnpm 11 is the default package manager (17 projects). What to know:

- Content-addressable store + a strict, non-flat `node_modules` — phantom
  dependencies (importing something you didn't declare) fail, which is a feature.
- Workspaces + `turbo` for the monorepos (gity-app, payment-app, tomoru).
- **Catalogs** (`catalog:` in `pnpm-workspace.yaml`) pin shared dependency
  versions in one place across a workspace — use them to keep React/Next/zod
  versions aligned across packages.
- Pin the pnpm version itself via `packageManager` in the root `package.json`.
