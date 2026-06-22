# API & idioms

The borrow checker enforces memory safety, not good API shape. These are the
reviewer-level calls, drawn from the Rust API Guidelines (the C-* conventions).

## Accept the general form in parameters

| Bad | Good | Why |
|---|---|---|
| `fn f(s: &String)` | `fn f(s: &str)` | takes literals and slices too |
| `fn f(v: &Vec<T>)` | `fn f(v: &[T])` | takes arrays, slices, any backing |
| `fn f(p: &Path)` | `fn f(p: impl AsRef<Path>)` | caller passes `&str`/`String`/`PathBuf` directly — but a tradeoff: it monomorphizes (code bloat) and isn't object-safe, so prefer plain `&Path` inside / for `dyn` traits, `impl AsRef` for ergonomic public entry points |
| `fn f(items: &Vec<T>)` (read-only) | `fn f(items: &[T])` | a slice borrows and yields `&T`; don't reach for `impl IntoIterator<Item = T>` here — that *consumes owned* `T`, a different contract (use `Item = &T` if you really want generic iteration) |

Return concrete types or `impl Iterator`; don't force a `Vec` allocation when the
caller might want to keep iterating.

## Conversions

```rust
// Bad: impl Into for your own type — redundant and non-idiomatic.
impl Into<Meters> for f64 { ... }

// Good: impl From; you get Into<Meters> for free, and `?` uses From.
impl From<f64> for Meters {
    fn from(v: f64) -> Self { Meters(v) }
}
```

Use `TryFrom`/`TryInto` for fallible conversions. The guideline (C-CONV-TRAITS):
implement `From`, never `Into`.

## Newtype for safety and the orphan rule

```rust
// A unit/ID wrapper the compiler keeps distinct (the Mars Climate Orbiter rule).
struct Meters(f64);
struct Feet(f64);
// Also lets you impl a foreign trait on a foreign type by wrapping it.
```

## Make illegal states unrepresentable

```rust
// Bad: three fields, several impossible combinations (connected + an error?).
struct Conn { connected: bool, session: Option<SessionId>, error: Option<Error> }

// Good: each state carries exactly its data; the impossible can't be built.
enum Conn {
    Disconnected,
    Connected(SessionId),
    Failed(Error),
}
```

Typestate takes this further: encode the state in a `PhantomData<State>` type
parameter so an invalid transition doesn't compile.

## Other reviewer checks

- **`?` over `match` for propagation** — `let x = f()?;` not a `match` that
  re-returns `Err`.
- **Iterator chains over index loops** — `.iter().filter().map().collect()` not
  `for i in 0..v.len()`. No bounds-panic risk, clearer intent.
- **Don't `.clone()` to dodge the borrow checker.** Borrow; clone only when it's
  cheap (`Arc`/`Rc` refcount bump, a `Copy` type) or you genuinely need a second
  owner. A reflexive `.clone()` hides an allocation.
- **`Cow<str>`** when the common path doesn't modify the input but the rare one
  does — avoids allocating on the no-change path.
- **Sealed traits** (a private supertrait) when a public trait must not be
  implemented downstream. **`#[non_exhaustive]`** on public structs/enums and
  **`#[must_use]`** on types/functions whose result must not be dropped.
- **Eagerly derive the common traits** (`Debug`, `Clone`, `PartialEq`, …) on
  public types unless there's a reason not to (C-COMMON-TRAITS).
