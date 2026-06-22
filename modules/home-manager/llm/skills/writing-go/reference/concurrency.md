# Concurrency

Goroutines are cheap; *leaked* goroutines are expensive and invisible. Every
review of concurrent code asks two questions: where does this goroutine get
joined, and how does it get cancelled? If either answer is "nowhere", it's a bug.

## The loopvar fix changed the rules

In a module declaring `go 1.22` or later, each loop iteration gets a fresh
variable. The classic capture bug is gone, and the old workaround is dead code:

```go
// Pre-1.22: this captured the same v — all goroutines saw the last value.
// go 1.22+: this is CORRECT. Each iteration has its own v.
for _, v := range items {
    go func() { handle(v) }()
}

// Dead code in 1.22+ modules. `go fix` (forvar modernizer) removes the shadow.
for _, v := range items {
    v := v            // <- delete this
    go func() { handle(v) }()
}
```

The semantics follow the `go` line in `go.mod`, not the toolchain. A module
still on `go 1.21` leaks; bump the line.

## context: propagate, don't store

```go
// Bad: context smuggled into a field, detached from the call tree.
type Worker struct{ ctx context.Context }

// Good: ctx flows as the first parameter, down to the leaf I/O call.
func (w *Worker) Run(ctx context.Context, job Job) error {
    rows, err := w.db.QueryContext(ctx, job.Query) // cancellation reaches the driver
    ...
}
```

- `context.Background()` appears once, at the top (main, a request boundary).
- A goroutine doing work selects on `ctx.Done()` and returns `ctx.Err()`.
- Don't put request-scoped values in context except true request scope
  (trace IDs, deadlines) — not optional config or dependencies.

## errgroup is the structured-concurrency workhorse

`golang.org/x/sync/errgroup` gives you fan-out with first-error cancellation and
a single join:

```go
g, ctx := errgroup.WithContext(ctx)
g.SetLimit(8) // bounded concurrency with backpressure; g.Go blocks when full

for _, u := range urls {
    g.Go(func() error {
        return fetch(ctx, u) // ctx is cancelled the instant any fetch fails
    })
}
if err := g.Wait(); err != nil { // returns the FIRST non-nil error
    return err
}
```

Why this beats a hand-rolled `sync.WaitGroup` + error channel: the derived `ctx`
is cancelled on the first error or when `Wait` returns, `Wait` surfaces that
error, and `SetLimit` caps concurrency without a semaphore channel.

For the plain wait-for-all case with no errors, Go 1.25's `WaitGroup.Go`
replaces the `Add`/`Done` boilerplate:

```go
var wg sync.WaitGroup
for _, t := range tasks {
    wg.Go(func() { t.Run() }) // Add(1) + defer Done() folded in
}
wg.Wait()
```

## Channels vs mutex

- **Mutex** protects shared state: a counter, a cache, a map. Reach for it first
  for "guard this field".
- **Channel** transfers ownership or builds a pipeline: producer → consumer,
  work distribution, signalling completion. "Share memory by communicating"
  means transferring data, not guarding a single int with a channel.
- A `sync.RWMutex` only helps under genuinely read-heavy contention; for short
  critical sections a plain `Mutex` is faster and simpler.

## Lazy init: OnceValue, not hand-rolled Once

```go
// Old: sync.Once + a captured package var.
var (
    once   sync.Once
    client *http.Client
)
func getClient() *http.Client {
    once.Do(func() { client = buildClient() })
    return client
}

// New (1.21): one expression, no shared mutable var.
var getClient = sync.OnceValue(func() *http.Client { return buildClient() })
```

`sync.OnceFunc` (no return), `OnceValue` (one return), `OnceValues` (two).

## When NOT to use a goroutine

- You never wait for it → it's a leak (work lost on shutdown, or worse, racing
  past the function that spawned it).
- One per item with no `SetLimit` → unbounded fan-out, OOM under load.
- A sequential loop is already fast enough and clearer → don't parallelize for
  style points; you've added a race surface for nothing.

## Testing concurrency

Use `testing/synctest` (GA in 1.25) instead of real sleeps — see
[testing.md](testing.md). Always run concurrent code under `go test -race`; the
race detector finds data races that no amount of review reliably will.
