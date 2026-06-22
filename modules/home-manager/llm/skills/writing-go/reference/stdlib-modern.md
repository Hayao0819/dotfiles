# Modern stdlib

Since Go 1.21 the standard library absorbed most of what used to be hand-written
or pulled from `golang.org/x` and third parties. Reaching for the old form now
reads as stale code. `go fix ./...` (1.26) mechanizes most of these.

## Old → new map

| Old | New | Since |
|---|---|---|
| `log.Printf`, logrus, zap-everywhere | `log/slog` (structured, leveled) | 1.21 |
| custom `contains`, `indexOf`, sort helpers | `slices.Contains`, `slices.Index`, `slices.SortFunc`, `slices.Sorted` | 1.21 |
| manual map iteration to collect keys/values | `maps.Keys`, `maps.Values`, `maps.Collect`, `maps.Clone` | 1.21 / 1.23 |
| custom `Less` / ordered constraint | `cmp.Ordered`, `cmp.Compare`, `cmp.Or` | 1.21 |
| `if a < b { … } else { … }` clamp | `min(a, b)` / `max(a, b)` | 1.21 |
| `for k := range m { delete(m, k) }` | `clear(m)` | 1.21 |
| `for i := 0; i < n; i++` (count loop) | `for i := range n` | 1.22 |
| `func ptr[T](v T) *T { return &v }` | `new(expr)` | 1.26 |
| `[]byte(fmt.Sprintf(...))` | `fmt.Appendf(buf, ...)` | modernizer |
| `i := strings.Index(s, sep); s[:i], s[i+1:]` | `strings.Cut(s, sep)` | 1.18 |
| custom collection walking | range-over-func + `iter.Seq` | 1.23 |

`errors.Join` is **1.20** (not 1.21) and `testing.T.Context()` is **1.24** (not
1.25) — two attribution traps.

## slog over log

```go
// Bad: unstructured, not queryable, no levels.
log.Printf("user %d login failed: %v", id, err)

// Good: structured key/values, leveled, one handler config away from JSON.
slog.Error("login failed", "user_id", id, "err", err)
```

Set up once in `main`:

```go
h := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo})
slog.SetDefault(slog.New(h))
```

Use `slog.With("request_id", id)` to attach context-wide fields. 1.26 adds
`slog.NewMultiHandler` to fan out to several handlers.

## slices / maps / cmp

```go
// Bad: reinventing the stdlib.
found := false
for _, x := range xs {
    if x == target { found = true; break }
}

// Good
found := slices.Contains(xs, target)

// Sorting structs
slices.SortFunc(users, func(a, b User) int {
    return cmp.Or(
        cmp.Compare(a.Last, b.Last),
        cmp.Compare(a.First, b.First),
    )
})
```

`cmp.Or` returns the first non-zero argument — handy for fallbacks
(`cmp.Or(cfg.Host, "localhost")`) and tie-broken comparisons.

## Iterators (range-over-func)

Since 1.23 a function can be ranged over. Write one when exposing a sequence
without materializing a slice:

```go
// iter.Seq2[K, V] — yields pairs until the consumer stops.
func (t *Tree) All() iter.Seq2[string, int] {
    return func(yield func(string, int) bool) {
        t.walk(func(k string, v int) bool { return yield(k, v) })
    }
}

for k, v := range tree.All() { // breaks/returns propagate into the iterator
    ...
}
```

Don't convert every helper into an iterator. Use one when callers genuinely
benefit from lazy, breakable iteration; a returned slice is simpler when the
data is already in memory and small.

## Pointers to literals (1.26)

```go
// Old: a generic helper in every codebase.
func ptr[T any](v T) *T { return &v }
cfg := Config{Timeout: ptr(30 * time.Second)}

// New: new() takes an expression.
cfg := Config{Timeout: new(30 * time.Second)}
```
