# API design

These are the judgments a linter can't make: where interfaces live, whether the
zero value works, when a generic earns its keep, and naming. They are also the
ones that age a codebase fastest when wrong.

## Accept interfaces, return concrete types — with the nuance

The slogan is real but routinely misapplied. The load-bearing rule is *where the
interface is declared*:

```go
// Bad: interface defined next to its only implementation, "for testing".
package store

type UserStore interface { Get(ctx context.Context, id int64) (*User, error) }
type pgStore struct{ ... }
func New(db *sql.DB) UserStore { return &pgStore{db} } // returns an interface, hides the type

// Good: constructor returns the concrete type. The CONSUMER declares the
// interface it needs, as narrow as its use.
package store
type Store struct{ ... }
func New(db *sql.DB) *Store { return &Store{db} }

package billing
type userGetter interface { // declared where it's used, only the method billing needs
    Get(ctx context.Context, id int64) (*User, error)
}
func Charge(ctx context.Context, g userGetter, id int64) error { ... }
```

Why: returning a concrete `*Store` lets callers reach new methods without you
widening an interface, and keeps godoc honest. The consumer-side interface stays
minimal and is trivially faked in tests.

The nuance — it's a guideline, not a law. Returning an interface is fine when you
genuinely have multiple implementations behind one constructor, or a sealed
sum-type-style API. The anti-pattern is the *speculative* producer-side
interface with exactly one implementation.

## Make the zero value useful

```go
// Bad: forces a constructor for something that could just work.
type Buffer struct{ buf []byte; initialized bool }
func NewBuffer() *Buffer { return &Buffer{initialized: true} }

// Good: zero value is ready. sync.Mutex, bytes.Buffer, strings.Builder set this bar.
type Buffer struct{ buf []byte }
var b Buffer // usable immediately
```

When the zero value can't be valid, a constructor is correct — but reach for it
because the type needs it, not by reflex.

## Generics: when they help, when they hurt

From the Go team's guidance: use a type parameter only when the *same* logic
repeats, varying only by type.

| Situation | Use |
|---|---|
| identical logic over many types (containers, `slices`/`maps`-style helpers) | type parameter |
| behavior differs per type | interface (method dispatch) |
| types have no methods and behavior differs (JSON) | reflection |

```go
// Good generic: logic is identical, only T varies.
func Keys[K comparable, V any](m map[K]V) []K {
    ks := make([]K, 0, len(m))
    for k := range m { ks = append(ks, k) }
    return ks
}

// Bad generic: a type param that only ever instantiates once, or that hides a
// behavior difference that wants an interface. "Write code, not types" —
// start with a function; add a type param once duplication is proven.
```

Type parameters are not a performance optimization over interfaces — don't
reach for them on a speed argument.

## any

`any` (`interface{}`) throws away the type system. Prefer a concrete type or a
type parameter; accept `any` only at genuine reflection boundaries
(`encoding/json`, a generic cache that truly stores anything). An `any`-typed
field or parameter in business logic is almost always a missing type.

## Naming (Google Go style)

- `MixedCaps` / `mixedCaps`, never `snake_case` or `SCREAMING_CASE`.
- Initialisms keep case: `URL`, `ID`, `HTTP`, `userID`, `ServeHTTP`,
  `parseURL` — not `Url`, `Id`, `userId`.
- Package names are short, lowercase, no underscores, and don't stutter:
  `chubby.File`, not `chubby.ChubbyFile`. The package qualifies the name.
- Variable name length scales inversely with scope: `i`, `r`, `b` in a tight
  loop; descriptive at package scope.
- Getters drop `Get`: `user.Name()`, not `user.GetName()`. Setters keep `Set`.

## Other reviewer-level checks

- **No in-band errors.** Return `(value, ok)` or `(value, error)`, never a magic
  sentinel value like `-1` or `""`.
- **Named returns sparingly** — for godoc clarity on multiple same-typed returns,
  or deferred mutation; not to save a `var`.
- **Early return.** Handle the error and `return`; keep the happy path at minimal
  indentation rather than nesting it inside `else`.
