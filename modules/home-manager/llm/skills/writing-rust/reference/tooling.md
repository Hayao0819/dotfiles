# Tooling

## Clippy lint groups

| Group | Default | Use |
|---|---|---|
| `correctness` | **deny** | real bugs — never allow |
| `suspicious`, `style`, `complexity`, `perf` | warn (together = `clippy::all`) | the baseline |
| `pedantic` | allow | opt in; many good lints, some noisy |
| `nursery` | allow | unstable lints, opt in selectively |
| `cargo` | allow | `Cargo.toml` hygiene |
| `restriction` | allow | à la carte only — never enable the whole group |

`missing_safety_doc` is in **`style`** and is already warn-by-default (part of
`clippy::all`) — you don't need to enable it. `undocumented_unsafe_blocks` lives
in `restriction` (allow-by-default), so enable that one explicitly if you write
`unsafe`. (Note `missing_safety_doc` only enforces the *presence* of a `# Safety`
section, not its quality.)

## Configure lints in Cargo.toml, not source

Use the `[lints]` table (build-tracked, supersedes scattered `#![warn(...)]`).
Set a group to `priority = -1` so specific overrides win:

```toml
# Cargo.toml — see assets/Cargo.lints.toml for a fuller starter
[lints.rust]
unsafe_code = "warn"

[lints.clippy]
all = { level = "warn", priority = -1 }
pedantic = { level = "warn", priority = -1 }
undocumented_unsafe_blocks = "warn"
```

For a workspace, put `[workspace.lints]` in the root and `[lints] workspace =
true` in each member (since 1.74).

## cargo deny vs cargo audit

- **`cargo audit`** — fast RustSec advisory + yanked-crate check (CVE scan).
- **`cargo deny check`** — broader policy via `deny.toml`: advisories +
  **licenses** + **bans** (duplicate versions) + **sources**. Use it in CI.

## miri

`cargo +nightly miri test` interprets your code to catch undefined behavior
(use-after-free, uninitialized reads, misaligned access, data races, Stacked/Tree
Borrows violations). Run it on any crate with `unsafe`.

## MSRV and the resolver

Declare `rust-version = "1.85"` in `Cargo.toml`. Resolver "3" is the edition-2024
default (needs 1.84+); `resolver.incompatible-rust-versions = "fallback"` prefers
dependency versions compatible with your MSRV. Bump the MSRV only in a minor
release and treat it as semver-relevant.

## rustfmt

`cargo fmt` — non-negotiable, no per-line opinions to review. Like every language
here, route formatting to the tool; spend review on what the tool can't see.
