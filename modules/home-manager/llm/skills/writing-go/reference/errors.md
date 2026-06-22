# Errors

The preferred backend is **`github.com/cockroachdb/errors`** — it's in 8+ of the
engineer's projects (ayaka, seedsn, nahi, user-registration, …, ~29 import
sites). It gives clean `%+v` stack traces with no ceremony, is actively
maintained (v1.14.0, 2026-06), and is compatible with stdlib `errors.Is`/`As`/
`Join` and 1.26 `errors.AsType`. The language debate is over (`try`/`?` rejected
2025-06), so `if err != nil` is permanent; the leverage is in *wrapping
discipline* and *capturing the stack once*.

Today the engineer imports `cockroachdb/errors` **directly** (all 29 sites) and
builds thin helpers on top of the direct import — e.g. `ayaka`'s
`internal/utils` has `WrapErr` plus a `HasStack` check (type-asserting the
cockroachdb `SafeFormatError` interface) to decide `WithMessage` vs `Wrap` and
avoid duplicate stacks. That helper *is* the "capture stack once" principle in
their real code; cite it as the pattern. Direct import is fine and current.

## Optional: an `internal/errors` wrapper (the engineer's going-forward preference)

It's the engineer's stated preference to introduce a thin project-local
`internal/errors` package that re-exports the chosen library's surface, so the
codebase depends on *their* `errors` and the backend stays swappable (to
`samber/oops`, stdlib-only, or whatever comes next) in one file. This is
aspirational — no project ships such a wrapper yet, and their one real wrapper
(`tomoru/api/internal/errlib`) wraps `rotisserie/eris`, not cockroachdb. Treat
the wrapper as a pattern to adopt in *new* projects, not a rule to enforce
against existing direct-import code (don't add a `depguard` "no direct import"
rule that would fail CI on every current repo).

```go
// internal/errors/errors.go — the only file that imports cockroachdb/errors.
package errors

import (
	stderrors "errors"

	cerrors "github.com/cockroachdb/errors"
)

// Re-export the surface the codebase actually uses.
func New(msg string) error                  { return cerrors.New(msg) }
func Newf(format string, a ...any) error     { return cerrors.Newf(format, a...) }
func Wrap(err error, msg string) error       { return cerrors.Wrap(err, msg) }
func Wrapf(err error, f string, a ...any) error { return cerrors.Wrapf(err, f, a...) }

// Delegate inspection to stdlib so call sites never import two error packages.
func Is(err, target error) bool              { return stderrors.Is(err, target) }
func As(err error, target any) bool          { return stderrors.As(err, target) }
func Join(errs ...error) error               { return stderrors.Join(errs...) }

// Optional: keep cockroachdb extras behind your own names so swapping is clean.
func WithHint(err error, hint string) error  { return cerrors.WithHint(err, hint) }
```

Then every other package imports the wrapper, never `cockroachdb/errors`:

```go
import "github.com/you/app/internal/errors"

var ErrUserNotFound = errors.New("user not found")

func (r *repo) Get(ctx context.Context, id int64) (*User, error) {
    u, err := r.q.GetUser(ctx, id)
    if err != nil {
        return nil, errors.Wrap(err, "querying user") // your package, your stack capture
    }
    return u, nil
}
```

Keep the wrapper genuinely thin — re-export, don't reinvent. Add helpers only
where the codebase repeats a pattern (a domain `NotFound(kind, id)` constructor,
say). If a new project adopts the wrapper, a `depguard` rule can keep imports
going through it — but only scope that to the new project, never retrofit it onto
the existing direct-import repos.

The examples below use `cerrors`/`errors` interchangeably to show the underlying
behavior; in real code today the call site imports `cockroachdb/errors` directly.

> Library status (verified 2026-06): `pkg/errors` is frozen (last real change
> Jan 2020) — present only as an indirect dep, never import it directly. `eris`
> backs the engineer's one real wrapper package (`tomoru/api/internal/errlib`);
> it's low-activity upstream (~no feature work since 2023), so don't reach for it
> in *new* code, but it's not something to rip out of errlib. `samber/oops`
> (slog/OTel context + stacks) is a possible future alternative for
> observability-heavy services — note it is **not** currently in the stack.

## Capture the stack once, at the origin

The dominant pitfall: calling a stack-capturing `Wrap` at *every* layer records a
fresh stack each time, so `%+v` on a deep chain prints several near-identical
stacks. Capture once at the leaf; add message-only context above with `%w`.

```go
import (
    "errors" // stdlib: Is, As, Join, AsType
    "fmt"

    cerrors "github.com/cockroachdb/errors"
)

// Bad: a stack at every layer → duplicate stacks, noisy chain.
func (r *repo) Get(ctx context.Context, id int64) (*User, error) {
    u, err := r.q.GetUser(ctx, id)
    if err != nil {
        return nil, cerrors.Wrap(err, "db query")   // stack #1
    }
    return u, nil
}
func (s *service) Get(ctx context.Context, id int64) (*User, error) {
    u, err := s.repo.Get(ctx, id)
    if err != nil {
        return nil, cerrors.Wrap(err, "service get") // stack #2 — duplicate
    }
    return u, nil
}

// Good: ONE stack capture at the leaf; plain %w for context above it.
func (r *repo) Get(ctx context.Context, id int64) (*User, error) {
    u, err := r.q.GetUser(ctx, id)
    switch {
    case errors.Is(err, sql.ErrNoRows):
        return nil, ErrUserNotFound                  // sentinel; carries a stack
    case err != nil:
        return nil, cerrors.Wrap(err, "querying user") // the single stack capture
    }
    return u, nil
}
func (s *service) Get(ctx context.Context, id int64) (*User, error) {
    u, err := s.repo.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("loading profile %d: %w", id, err) // message only, no new stack
    }
    return u, nil
}
```

Print `%+v` once at the boundary (HTTP middleware, the `main` sink, the logger)
to get the message chain plus the single stack; use `%v`/`%s` for the one-line
user-facing form. cockroachdb/errors won't duplicate a trace when it re-wraps an
error that already has one, but "stack at the bottom, `%w` above" is the rule to
review for.

## Sentinels vs custom types

- **Sentinel** (`var ErrX = cerrors.New("…")`): when callers branch on *identity*.
  Use `cerrors.New` so the sentinel carries a stack from its definition site.
- **Custom type**: when callers need *structured data* (a code, a field). Give it
  `Error() string`; extract it with `errors.AsType` (1.26).

```go
var ErrUserNotFound = cerrors.New("user not found")

type ValidationError struct{ Field string }
func (e *ValidationError) Error() string { return "invalid field: " + e.Field }
```

## Inspecting — stdlib functions traverse cockroachdb wraps

| Want | Use | Since |
|---|---|---|
| match a sentinel through the chain | `errors.Is(err, ErrX)` | 1.13 |
| extract a typed error | `errors.As(err, &target)` | 1.13 |
| extract a typed error, generic + alloc-free | `errors.AsType[*T](err)` | **1.26** |
| aggregate independent errors | `errors.Join(e1, e2)` | **1.20** |

```go
if errors.Is(err, ErrUserNotFound) { ... }            // works through %w and cerrors.Wrap

// 1.26 idiom: type-safe, ~10x faster than errors.As, no reflection.
if ve, ok := errors.AsType[*ValidationError](err); ok {
    return badRequest(ve.Field)
}

// Aggregate, then one stack over the joined set.
if errs := errors.Join(validateName(u), validateEmail(u)); errs != nil {
    return cerrors.Wrap(errs, "validating user")
}
```

Prefer stdlib `errors.Join` over `hashicorp/go-multierror` in new code (keep the
latter only where its `*multierror.Error` API is already relied on).

## cockroachdb extras worth using

```go
err = cerrors.WithHint(err, "retry with a valid email")       // user/operator hint
err = cerrors.WithDetail(err, "validator=email rule=rfc5322") // structured detail (logs/Sentry)
```

`WithHint`/`WithDetail` separate user-facing guidance from operator detail, and
the library's redaction keeps PII out of Sentry. Reach for these instead of
stuffing everything into the wrap message.

## When stdlib-only is the right call

Don't import a heavy error dependency into a **library / public module** — leave
importers free; use `fmt.Errorf("%w")` + `errors.Is/As/Join/AsType` there. Same
for tiny CLIs where structured logging already carries the context. cockroachdb
pulls in a protobuf/gogoproto tree (the network-portability + redaction cost) —
worth it for services, not for a leaf library.

## Style the reviewer enforces

- Error strings: lowercase, no trailing punctuation, so they compose inside
  `Wrap`/`Errorf`.
- Don't log *and* return the same error — the top of the stack logs `%+v`;
  everything below returns.
- `panic` is for programmer bugs and unrecoverable init, not ordinary failures;
  recover only at a defined boundary (a request handler), never as control flow.
- On `err != nil`, leave the other return values in their zero state.
