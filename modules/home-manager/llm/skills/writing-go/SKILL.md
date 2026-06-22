---
name: writing-go
description: >-
  Idiomatic, version-current Go review and authoring for an experienced
  engineer. Covers deliberate error wrapping (errors.Is/As/Join, AsType),
  structured concurrency (errgroup, context, the loopvar fix), modern stdlib
  that replaced old patterns (slices/maps/cmp, log/slog, min/max/clear,
  range-over-func iterators), table-driven and synctest testing, API design
  the linter can't check, and Gin/GORM/cobra backend patterns. Use when
  writing, reviewing, or refactoring Go — .go files, go.mod, goroutines,
  errors.Is/As, a Go backend or CLI — or before committing Go. Flags outdated
  pre-1.22 idioms (loopvar v:=v shadows, tools.go, hand-rolled helpers).
---

# Writing Go

This skill is a reviewer sitting next to you, not a tutorial. It assumes you
already know `if err != nil`, interfaces, goroutines, slices, and defer. It
spends its budget on what is **non-obvious**, what **changed recently**, and
what a **linter won't catch**. Anything the compiler or `golangci-lint` already
enforces is out of scope — run the tool, don't restate its rules.

> Compatibility: Go 1.26 is current (released 2026-02), but this engineer's
> modules are on **go 1.22–1.25** today. Version gates below name the release a
> feature landed in. Semantics (the loopvar fix, range-int) AND the 1.26 stdlib
> APIs (`errors.AsType`, `new(expr)`, `go fix` modernizers, `slog.NewMultiHandler`)
> are gated by the `go` line in `go.mod` — treat them as upgrade targets, not as
> already-present, until that line is bumped. (cockroachdb/errors past v1.13
> also requires go 1.25.)

## When to use

- Reviewing or writing any `.go` file or editing `go.mod`.
- Deciding how to wrap an error, structure concurrency, or shape an API.
- Refactoring older Go and unsure which idioms are now legacy.
- Before committing Go: run the tooling pass at the bottom.

If the task is purely mechanical formatting, just run `gofumpt`/`gofmt -s` and
stop — that is not what this skill is for.

## How to read this skill

The tables below are the fast path. When a topic needs depth, open the matching
reference file — each is loaded only when you read it:

| Open this | When |
|---|---|
| [reference/errors.md](reference/errors.md) | wrapping, sentinels, custom types, `errors.AsType` |
| [reference/concurrency.md](reference/concurrency.md) | goroutine lifetime, `context`, `errgroup`, when not to |
| [reference/stdlib-modern.md](reference/stdlib-modern.md) | the full old→new replacement map and iterators |
| [reference/testing.md](reference/testing.md) | table-driven, subtests, `synctest`, testify pitfalls |
| [reference/api-design.md](reference/api-design.md) | interfaces, zero values, generics-vs-not, naming |
| [reference/web-backend.md](reference/web-backend.md) | net/http 1.22 routing, Gin, GORM vs sqlc, shutdown |

## What changed — stop writing the old form

A lot of pre-2023 Go advice is now legacy. `go fix ./...` (1.26) rewrites most
of it mechanically; run it twice for chained fixes.

| Old form | Modern form | Since |
|---|---|---|
| `v := v` before `go func(){…use(v)…}()` | nothing — loop var is per-iteration | 1.22 |
| `for i := 0; i < n; i++` (counting) | `for i := range n` | 1.22 |
| `log.Printf` / logrus / zap-for-everything | `log/slog` | 1.21 |
| hand-rolled `contains` / `indexOf` / sort | `slices.Contains`, `slices.SortFunc` | 1.21 |
| manual map key/value loops | `maps.Keys` / `Values` / `Collect` | 1.23 |
| custom `Less` / ordered constraints | `cmp.Ordered`, `cmp.Compare`, `cmp.Or` | 1.21 |
| `if a < b {…} else {…}` clamps, `m = map{}` reset | `min` / `max` / `clear` | 1.21 |
| `func ptr[T](v T) *T` helper | `new(expr)` | 1.26 |
| `errors.As(err, &target)` in new code | `errors.AsType[T](err)` | 1.26 |
| `tools.go` + blank imports | `tool` directive in `go.mod` | 1.24 |
| `wg.Add(1); go func(){ defer wg.Done()… }()` | `wg.Go(func(){…})` | 1.25 |
| `sync.Once` + captured var for lazy init | `sync.OnceValue` / `OnceFunc` | 1.21 |
| Gin/chi solely for `/items/{id}` path params | `http.ServeMux` method+wildcard patterns | 1.22 |
| `select{ case <-ch:; case <-time.After: }` tests | `testing/synctest` fake clock | 1.25 |
| mental model waiting for `try` / `?` | `if err != nil` — syntax change rejected | 2025-06 |

## Highest-leverage review checks

These are the ones reviewers catch and tools miss. Each links to depth.

- **Errors go through a thin `internal/errors` wrapper over `cockroachdb/errors`,
  with the stack captured once at the origin.** Don't import the library
  directly — wrap it so it stays swappable. Wrap at the leaf; add message-only
  context above with plain `%w` for one clean `%+v` stack, not a duplicate per
  layer. → [errors.md](reference/errors.md)
- **Every goroutine needs a join point and a cancellation path.** A goroutine
  with no `Wait`/`errgroup` and no `ctx.Done()` is a leak, not concurrency.
  → [concurrency.md](reference/concurrency.md)
- **`context.Context` is the first argument, never a struct field.** Top-level
  `context.Background()` only; everything below takes `ctx`.
- **Define interfaces in the consumer, return concrete types from constructors.**
  An interface declared next to its only implementation "for mocking" is the
  anti-pattern. → [api-design.md](reference/api-design.md)
- **Design the zero value to be useful** before writing a mandatory
  constructor (`sync.Mutex`, `bytes.Buffer` set the bar).
- **`require.*` runs on the test goroutine only.** Calling it from a spawned
  goroutine or HTTP handler triggers `Goexit` on the wrong goroutine. Use
  `assert` there. → [testing.md](reference/testing.md)
- **`any` discards type safety** — reach for a concrete type or a type
  parameter first; reflection (`encoding/json`) is the justified exception.

## Tooling pass (before commit)

Run these, not a prose re-derivation of them:

```sh
gofumpt -l -w .      # stricter superset of gofmt -s
go vet ./...         # printf, struct tags, lost cancel, ...
go fix ./...         # modernize idioms (1.26); run twice
golangci-lint run    # v2: errcheck govet ineffassign staticcheck unused + your adds
govulncheck ./...    # only reports vulns your code actually reaches
go test ./... -race  # the race detector catches what review won't
```

`golangci-lint` v2 changed its config format; `golangci-lint migrate` upgrades a
v1 `.golangci.yml`. A starting config is in
[assets/golangci.reference.yml](assets/golangci.reference.yml) — adopt per repo,
don't impose it where the project already has one.

## What this skill is not

- Not a Go tutorial and not a restatement of `golangci-lint`, `go vet`, or the
  compiler. If a tool enforces it, route to the tool.
- Not a license to rewrite working code into the newest idiom for its own sake.
  Flag legacy forms; change them when touching that code, not as a sweep.
- Prose this skill helps you write (comments, docs, commit messages) still goes
  through **natural-writing** — keep comments to *why*, not *what*.
