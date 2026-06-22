# Evals — writing-go

Three scenarios that test what this skill adds over a stock model. Run each in a
fresh session twice — once with the skill available, once disabled — and check
both (a) that the skill triggers when it should and (b) that the output improves.
Pass criteria are behavioral, not exact strings.

## 1. Trigger + error-wrapping discipline

**Query:** "Review this store method." (paste a method that does
`return fmt.Errorf("get user: %w", sql.ErrNoRows)` and exposes the driver
sentinel through its public API)

**Expected behavior:**
- Skill triggers on the Go review request without being named.
- Flags that `%w` leaks `sql.ErrNoRows` into the package's public contract.
- Recommends translating to a package-owned sentinel (`ErrUserNotFound`) and
  using `%v` to break the chain, or `%w` only if the inner error is deliberately
  part of the API.
- Does not invent a rule the compiler/linter already enforces.

## 2. Stale-idiom detection

**Query:** "Is there anything outdated in this Go code?" (paste code with a
`v := v` loop shadow before a goroutine, a hand-rolled `contains`, `log.Printf`,
and a `tools.go` reference — in a module on `go 1.24`)

**Expected behavior:**
- Identifies the `v := v` shadow as dead code in go 1.22+ modules and explains
  the loopvar fix.
- Suggests `slices.Contains` for the hand-rolled loop and `log/slog` for logging.
- Notes `tools.go` is replaced by the `tool` directive in go.mod (1.24).
- Mentions `go fix ./...` can apply most of these mechanically.
- Attributes each change to the correct Go version.

## 3. Concurrency review

**Query:** "Does this fan-out look right?" (paste a loop spawning a goroutine per
item with a bare `sync.WaitGroup`, an error swallowed in each goroutine, and no
context cancellation)

**Expected behavior:**
- Points out there is no cancellation path and the first error is lost.
- Recommends `errgroup.WithContext` with `SetLimit` for bounded concurrency and
  first-error propagation.
- Notes the goroutines should select on `ctx.Done()`.
- If testing comes up, points to `synctest` rather than real sleeps and to
  `go test -race`.

## Notes

- Test on Haiku, Sonnet, and Opus: Haiku checks the guidance is sufficient,
  Opus checks the skill doesn't over-explain things the model already knows.
- A regression to watch: the skill should NOT fire for pure `gofmt`-only
  requests or non-Go files.
