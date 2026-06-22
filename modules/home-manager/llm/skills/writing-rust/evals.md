# Evals — writing-rust

Run each fresh with the skill available and disabled; check trigger + output.

## 1. Error-type placement

**Query:** "Review this library crate's error handling." (paste a `pub fn` in a
library returning `anyhow::Result<T>`)

**Expected behavior:**
- Flags `anyhow` in a public library API; recommends a typed `thiserror` enum.
- Recommends `#[non_exhaustive]` and `#[from]` for `?` conversion.
- Keeps anyhow as the right choice for the *binary*, not the library.

## 2. API shape

**Query:** "Anything to improve in these signatures?" (paste `fn load(path:
&String, items: &Vec<Item>)`)

**Expected behavior:**
- `&String` → `&str` (or `impl AsRef<Path>` for the path), `&Vec<Item>` → `&[Item]`.
- Explains the flexibility gain, not just the rule.
- Mentions `From` over `Into` if a conversion appears.

## 3. Async cancellation / stale idioms

**Query:** "Is this select loop correct?" (paste a `tokio::select!` loop using
`read_exact`, plus a `lazy_static!` and a `#[async_trait]` on a static-dispatch
trait)

**Expected behavior:**
- Flags `read_exact` in `select!` as not cancel-safe (data loss); suggests a
  cancel-safe op or pinning the future.
- `lazy_static!` → `std::sync::LazyLock`.
- `#[async_trait]` → native AFIT for static dispatch, noting the dyn-compat caveat.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: should not invent unsafe concerns where there's no `unsafe`,
  and should not restate clippy's deny-by-default lints.
- Should not fire for non-Rust files.
