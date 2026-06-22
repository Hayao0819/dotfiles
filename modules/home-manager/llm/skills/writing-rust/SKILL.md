---
name: writing-rust
description: >-
  Idiomatic, version-current Rust review and authoring for an experienced
  engineer on edition 2024 / Rust 1.9x. Covers error handling (thiserror in
  libraries, anyhow in binaries, #[non_exhaustive], #[from]/transparent), API
  idioms the borrow checker won't catch (&str/&[T] params, From over Into,
  newtype, builder, sealed traits, making illegal states unrepresentable), async
  cancellation safety and non-Send-across-await with tokio, unsafe documentation,
  and the clippy/cargo-deny/[lints] tooling. Use when writing or reviewing Rust —
  .rs files, Cargo.toml, traits, error enums, async — or before committing Rust.
  Flags outdated forms (lazy_static, structopt, manual async-trait where AFIT works).
---

# Writing Rust

A reviewer for someone who already knows ownership, borrowing, traits, and `?`.
It spends its budget on the idioms the borrow checker *doesn't* enforce, the
error/API conventions that age a crate, and the async sharp edges that compile
fine and then lose data at runtime. The model is a clean CLI-plus-libraries
workspace on edition 2024.

> Compatibility (re-verify on ship): Rust 1.96, edition 2024 (stabilized 1.85).
> thiserror 2.0, anyhow 1.0, tokio 1.x. Declare an MSRV with `rust-version` and
> bump it only in minor releases.

## When to use

- Writing or reviewing any `.rs` or editing `Cargo.toml`.
- Designing an error type, a public API, or async/concurrency code.
- Before committing Rust: run the tooling pass at the bottom.

## How to read this skill

| Open this | When |
|---|---|
| [reference/errors.md](reference/errors.md) | thiserror vs anyhow, `#[from]`/`transparent`, `#[non_exhaustive]`, panic policy |
| [reference/idioms.md](reference/idioms.md) | API params, From/TryFrom, newtype, builder, sealed, illegal states |
| [reference/async.md](reference/async.md) | tokio, cancellation safety, non-Send across await, when not to go async |
| [reference/tooling.md](reference/tooling.md) | clippy groups, the `[lints]` table, cargo deny/audit, miri, MSRV |

## What changed — stop writing the old form

| Old form | Modern form | Since |
|---|---|---|
| `lazy_static! { ... }` / `once_cell` crate | `std::sync::LazyLock` / `LazyCell` | 1.80 |
| `once_cell::OnceCell` | `std::sync::OnceLock` / `OnceCell` | 1.70 |
| `#[async_trait]` for static dispatch | native `async fn` in traits (AFIT) | 1.75 (keep `#[async_trait]` only for `dyn Trait`) |
| `structopt` | `clap` derive (`#[derive(Parser)]`) | clap 4 |
| `failure` crate | `thiserror` (libs) / `anyhow` (apps) | — |
| `let x = match opt { Some(x) => x, None => return }` | `let Some(x) = opt else { return }` | 1.65 |
| `format!("{}", x)` | inline captures `format!("{x}")` | 1.58 (idents only) |
| nested `if let { if let { … } }` | `if let … && let … ` (let-chains) | 1.88 / edition 2024 |
| `extern "C" { ... }` (edition 2024) | `unsafe extern "C" { ... }` | edition 2024 |
| `#[no_mangle]` (edition 2024) | `#[unsafe(no_mangle)]` | edition 2024 |

## Highest-leverage review checks

- **thiserror in libraries, anyhow in binaries — never the reverse.** A public
  library returns a typed `thiserror` enum callers can `match`; an application
  returns opaque `anyhow::Error` with `.context()`. Don't expose `anyhow::Error`
  in a public API. → [reference/errors.md](reference/errors.md)
- **`#[non_exhaustive]` on every public error enum** so adding a variant isn't a
  breaking change. Implement `Error`; `#[from]` to make `?` convert.
- **Accept the borrowed/general form in APIs:** `&str` not `&String`, `&[T]` not
  `&Vec<T>`, `impl AsRef<Path>` not `&Path`, `impl IntoIterator` not `&Vec<T>`.
  Implement `From`, never `Into` (you get `Into` free). → [reference/idioms.md](reference/idioms.md)
- **Make illegal states unrepresentable.** Replace a struct of `bool` +
  `Option<_>` flags with an enum whose variants carry exactly the data that
  state has. Parse, don't validate.
- **Async cancellation safety is not free.** In a `select!` loop, `read_exact` /
  `write_all` / a `tokio::Mutex::lock` dropped mid-flight lose data or queue
  position. Know which ops are cancel-safe before putting them in `select!`.
  → [reference/async.md](reference/async.md)
- **Don't hold a non-`Send` guard across `.await`** (a `std::MutexGuard`, an
  `Rc`, a `RefCell` borrow) — the future stops being `Send` and `spawn` rejects
  it. Scope the guard out before awaiting.
- **Every `unsafe` gets a `// SAFETY:` comment; every public `unsafe fn` a
  `/// # Safety` section.** Reach for `unsafe` only when there's no safe way.

## Tooling pass (before commit)

```sh
cargo fmt
cargo clippy --all-targets -- -D warnings  # correctness is deny-by-default
cargo test
cargo deny check                           # advisories + licenses + bans + sources
# cargo +nightly miri test                 # for any unsafe code
```

Configure lints in a `[lints]` (or `[workspace.lints]`) table in `Cargo.toml`,
not scattered `#![warn(...)]` — see [reference/tooling.md](reference/tooling.md)
and the starter in [assets/Cargo.lints.toml](assets/Cargo.lints.toml).

## What this skill is not

- Not a Rust tutorial and not a restatement of clippy or the compiler. Route lint
  to the tool.
- The async section is dense even though much code here is sync — it's the
  highest-value non-obvious material, so it's kept whether or not today's file is
  async.
- Prose it helps you write (doc comments, README) goes through **natural-writing**.
