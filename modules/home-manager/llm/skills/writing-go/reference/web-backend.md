# Web / backend (Gin, GORM, cobra)

The engineer's backends are uniformly **Gin + GORM** (Gin pervasive, GORM at ~45
import sites; no sqlc, no stdlib-`ServeMux` routing in the codebase). Spend the
review budget there.

## GORM review checks (the linter won't catch these)

GORM is the data layer everywhere — these are the high-value, non-obvious checks:

- **N+1 from a missing `Preload`.** Iterating records and lazy-loading an
  association per row is the classic N+1. Eager-load with `Preload("Assoc")` (or
  `Joins`) when you'll touch the association.
- **Forgetting `WithContext(ctx)`** so request cancellation/timeout never reaches
  the query: `h.db.WithContext(ctx).First(&u, id)`. A cancelled `r.Context()`
  then cancels the in-flight query in `database/sql`.
- **`ErrRecordNotFound` handling:** check `errors.Is(err, gorm.ErrRecordNotFound)`,
  not a driver sentinel; a bare `First` returns it and is easy to mishandle.
- **Soft delete surprises:** a `gorm.DeletedAt` field silently adds
  `WHERE deleted_at IS NULL` to every query; use `Unscoped()` deliberately when
  you need the soft-deleted rows.
- **Transactions:** wrap multi-write units in `db.Transaction(func(tx *gorm.DB)
  error { ... })`; don't thread a raw `*gorm.DB` and hope.
- **Mass assignment / SQL injection** via raw escape hatches (`Raw`/`Exec` + string
  concatenation, raw `Order`/`Where` fragments) — for the security angle on these,
  see the **auditing-web-app** skill.

Never store the context in a struct field — pass `r.Context()` through.

## net/http routing (context only — Gin is the engineer's framework)

Since 1.22 `http.ServeMux` does method+wildcard routing
(`mux.HandleFunc("POST /items/{id}", …)` + `r.PathValue("id")`), so stdlib alone
can handle path params for a small service. The engineer uses Gin everywhere
(no `PathValue` in the codebase), so this is context, not a recommendation to
switch — review against Gin's binding/middleware model below.

## Graceful shutdown

Required for any service behind a load balancer or in k8s — abrupt exit kills
in-flight requests on every rollout:

```go
func main() {
    ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
    defer stop()

    srv := &http.Server{Addr: ":8080", Handler: mux}
    go func() {
        if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
            slog.Error("listen", "err", err)
            os.Exit(1)
        }
    }()

    <-ctx.Done() // first SIGINT/SIGTERM
    shutdownCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
    defer cancel()
    if err := srv.Shutdown(shutdownCtx); err != nil { // drain in-flight requests
        slog.Error("shutdown", "err", err)
    }
}
```

For a cobra CLI, thread that signal context through `cmd.ExecuteContext(ctx)` so
long-running commands cancel on the same signal.

## Container-aware GOMAXPROCS (1.25)

Go 1.25 makes the runtime honor cgroup CPU limits, so `GOMAXPROCS` matches the
container quota instead of the host's core count. You usually no longer need
`automaxprocs` (uber-go) for correct scheduling under k8s CPU limits — drop the
dependency on 1.25+.

## Gin specifics worth a review note

- Bind with the right method: `ShouldBindJSON` returns an error you handle;
  `MustBindWith` aborts with 400 automatically — don't mix the two mental models.
- Validate at the boundary with struct tags; don't trust handler inputs deeper
  in the stack.
- Put `gin.Recovery()` and a structured-logging middleware (feeding `slog`) at
  the top of the chain; don't `log.Println` per handler.
