# Testing

Table-driven tests with subtests are the default structure. Beyond that, the
high-value, easy-to-miss points are `synctest` for time-dependent code, the
`require`-on-wrong-goroutine trap, and knowing when a mock is the wrong tool.

## Table-driven + subtests

```go
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        in      string
        want    Value
        wantErr bool
    }{
        {"empty", "", Value{}, true},
        {"simple", "a=1", Value{"a", 1}, false},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel() // safe in go 1.22+ without a tt := tt shadow
            got, err := Parse(tt.in)
            if (err != nil) != tt.wantErr {
                t.Fatalf("err = %v, wantErr %v", err, tt.wantErr)
            }
            if got != tt.want {
                t.Errorf("got %+v, want %+v", got, tt.want)
            }
        })
    }
}
```

The `tt := tt` capture shadow is only needed for Go < 1.22; drop it in modern
modules (same loopvar fix as [concurrency.md](concurrency.md)).

## testing.T.Context() (1.24)

A context cancelled automatically at test cleanup — use it instead of threading
`context.Background()` and a manual cancel:

```go
func TestFetch(t *testing.T) {
    got, err := Fetch(t.Context(), url) // cancelled when the test ends
    ...
}
```

## synctest for time-dependent tests (GA 1.25)

Stop testing timeouts with real sleeps. `synctest.Test` runs the body in a
bubble with a fake clock that advances only when every goroutine in the bubble
is durably blocked:

```go
// Bad: slow and flaky — real wall-clock, racing the scheduler.
func TestDebounce(t *testing.T) {
    d := NewDebouncer(100 * time.Millisecond)
    d.Trigger()
    time.Sleep(150 * time.Millisecond)
    if !d.Fired() { t.Fatal("expected fire") }
}

// Good: deterministic, instant. Fake clock jumps exactly 100ms.
func TestDebounce(t *testing.T) {
    synctest.Test(t, func(t *testing.T) {
        d := NewDebouncer(100 * time.Millisecond)
        d.Trigger()
        time.Sleep(100 * time.Millisecond) // virtual time
        synctest.Wait()                    // all bubble goroutines settled
        if !d.Fired() { t.Fatal("expected fire") }
    })
}
```

Durable blockers that advance the fake clock: channel ops, `time.Sleep`,
`Cond.Wait`, `WaitGroup.Wait`. Mutexes and real I/O do **not** — keep those out
of the bubble. (The 1.24 preview API was `synctest.Run`; 1.25 GA is
`synctest.Test`.)

## Benchmarks: b.Loop (1.24)

```go
// Old
func BenchmarkX(b *testing.B) {
    for i := 0; i < b.N; i++ { X() }
}
// New: setup/teardown run once, results are more stable.
func BenchmarkX(b *testing.B) {
    for b.Loop() { X() }
}
```

## testify pitfalls

- `require.*` fails fatally (`t.FailNow`); `assert.*` records and continues.
  Use `require` for preconditions, `assert` for independent body checks.
- **`require` must run on the test goroutine.** Calling it inside a spawned
  goroutine or an HTTP handler invokes `runtime.Goexit` on the wrong goroutine —
  undefined behavior and races. Use `assert` there and signal failure back to
  the test goroutine. `testifylint` flags this; enable it.

```go
// Bad: require inside the handler goroutine.
srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    require.Equal(t, "POST", r.Method) // Goexit on the server goroutine
}))

// Good: assert, and let the response carry the failure.
srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    assert.Equal(t, "POST", r.Method)
}))
```

## When to avoid mocks

Mocks split the test between the test body and the mock's scripted behavior, so
tests fail when the *mock* is wrong, not the code. Prefer, in order:

1. The real implementation (a temp dir, `httptest.Server`, an in-memory store).
2. A small hand-written fake that implements the consumer's interface.
3. A generated mock — only when the dependency is genuinely external and slow.

Don't extract an interface *solely* to mock it; that's the producer-side
interface anti-pattern from [api-design.md](api-design.md).

## Fuzzing

For anything parsing untrusted bytes (decoders, parsers, validators), add a
`func FuzzX(f *testing.F)` with seed corpus and `f.Fuzz`. Stable since 1.18.
