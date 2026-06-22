# Errors

The split is the whole discipline: **thiserror for libraries, anyhow for
applications.** anyhow's own docs say it — "anyhow targets applications, while
thiserror suits libraries." A library returns a typed enum callers can `match`;
a binary returns an opaque error with context. Never expose `anyhow::Error` (or
`eyre::Report`) in a public library signature.

## thiserror in a library

```rust
use std::path::PathBuf;

#[derive(Debug, thiserror::Error)]
#[non_exhaustive] // adding a variant later is not a breaking change
pub enum StoreError {
    #[error("package {name} not found")]
    NotFound { name: String },

    #[error("reading {path}")]
    Io {
        path: PathBuf,
        #[source]            // wraps the cause; powers `?` and the error chain
        source: std::io::Error,
    },

    #[error(transparent)]    // forward Display + source for a single-wrap variant
    Hash(#[from] HashError), // #[from] generates From, so `?` converts automatically
}
```

- `#[from]` generates `From` and marks the `source` — it's what makes `?` work.
- `#[error(transparent)]` forwards `Display`/`source` for a catch-all or
  single-wrap variant (don't add your own message).
- `#[non_exhaustive]` on every public error enum: future variants stay
  non-breaking, and downstream `match` must carry a `_ =>` arm.
- Define a typed enum when callers branch on the failure mode; a boxed/opaque
  error when they don't.

## anyhow in a binary

```rust
use anyhow::{Context, bail};

fn run(path: &Path) -> anyhow::Result<()> {
    let cfg = std::fs::read_to_string(path)
        .with_context(|| format!("reading config {}", path.display()))?; // lazy context
    if cfg.is_empty() {
        bail!("config {} is empty", path.display());
    }
    Ok(())
}
```

`.context("...")` for a static message, `.with_context(|| ...)` when building the
message costs something. `eyre` + `color-eyre` is the alternative when you want
swappable, prettier reports — same shape, `WrapErr::wrap_err`.

## panic policy

Return `Result` for *expected* failures. `panic!` / `expect` / `unwrap` are for
**broken invariants (bugs)**, prototypes, and tests. The convention is
`expect("<the invariant that guarantees this succeeds>")`, not a bare `unwrap()`:

```rust
// Bad: silent, reasonless.
let port = env.get("PORT").unwrap();

// Good in app code: a parse with context.
let port: u16 = env.get("PORT").context("PORT not set")?.parse().context("PORT not a number")?;

// Good for a true invariant: explain why it can't fail.
let first = non_empty.first().expect("non_empty is guaranteed to have >= 1 element");
```

Never `unwrap`/`expect` in library code paths a caller can reach with bad input —
return an error instead.

## thiserror 2.0 notes

- `no_std` support (pairs with `core::error::Error`, 1.81) — `default-features =
  false`.
- A direct `thiserror` dependency is now required (it's no longer re-exported).
- Format args follow normal rules: `{path}` for a field named `path`, positional
  `{0}` can't mix with extra positional args.
