---
name: writing-zig
description: >-
  Idiomatic, version-current Zig review and authoring for an experienced
  engineer, pinned to Zig 0.15.2 (with 0.16.0 deltas flagged). Covers explicit
  allocator passing and choosing allocators, named error sets at API boundaries
  with try/errdefer, the post-Writergate std.Io.Reader/Writer interface,
  unmanaged std.ArrayList, sparse comptime, slices-over-pointers and tagged-union
  idioms, and the modern build.zig/build.zig.zon module API. Use when writing or
  reviewing Zig — .zig files, build.zig, build.zig.zon — or hitting a version
  break. Flags pre-0.14/0.15 forms (managed ArrayList, getStdOut().writer(),
  usingnamespace, async keywords, flat addExecutable, TitleCase @typeInfo tags).
---

# Writing Zig

Zig is pre-1.0 and the standard library churns hard between minor versions, so
**version accuracy is the whole game** — advice from a 0.12 tutorial is often a
compile error now. This skill is pinned to **Zig 0.15.2** (matching the gp-wrapper
project's `minimum_zig_version`) and flags where **0.16.0** differs. The existing
gp-wrapper patterns are already idiomatic modern Zig; this skill codifies them and
guards against regressions.

> Compatibility: examples target **Zig 0.15.2**. Current stable is 0.16.0 as of
> 2026-06 (released 2026-04) — but 0.17 is in a short release cycle, so re-check
> ziglang.org/download before trusting version claims. gp-wrapper holds at 0.15.2
> because a dependency (zig-gobject 0.3.1) still emits `@Type`, removed in 0.16
> (and its build.zig also forces the LLVM backend to dodge a 0.15 self-hosted x86
> ELF linker bug on glibc 2.43+ — don't flag `use_llvm`/`-Dself-hosted` as cruft).
> The idioms apply to both; the 0.15→0.16 deltas are in
> [reference/build-tooling.md](reference/build-tooling.md).

## When to use

- Writing or reviewing any `.zig`, `build.zig`, or `build.zig.zon`.
- Diagnosing a version-break compile error (the std API moved under you).

## How to read this skill

| Open this | When |
|---|---|
| [reference/memory.md](reference/memory.md) | passing allocators, choosing one, defer/errdefer, leak-checked tests |
| [reference/errors.md](reference/errors.md) | error sets, inferred vs explicit, try/catch/errdefer, `unreachable` |
| [reference/idioms.md](reference/idioms.md) | slices vs pointers, tagged unions, comptime, the post-Writergate I/O API |
| [reference/build-tooling.md](reference/build-tooling.md) | build.zig modules, build.zig.zon, the 0.15→0.16 deltas |

## What changed — these pre-0.14/0.15 forms no longer compile

| Old form | Modern form | Broke at |
|---|---|---|
| `std.io.getStdOut().writer()`, `bufferedWriter` | `std.fs.File.stdout().writeAll(...)`; `std.Io.Writer` + explicit buffer | 0.15.1 (Writergate) |
| generic `std.io.Reader`/`Writer`, `AnyReader`, `FixedBufferStream` | concrete `std.Io.Reader`/`std.Io.Writer`; `std.Io.Writer.Allocating` | 0.15.1 / deleted 0.16 |
| `var l = std.ArrayList(T).init(a); l.append(x)` | `var l: std.ArrayList(T) = .empty; l.append(a, x)` | 0.15.1 (unmanaged default) |
| `usingnamespace` | explicit re-exports / `pub const x = ...` | 0.15.1 (removed) |
| `async` / `await` / `@frameSize` keywords | the `std.Io` async interface (`Future`, `io.async`) | removed 0.15.1, lib form 0.16 |
| `addExecutable(.{ .root_source_file = ..., .target = ... })` flat | `.root_module = b.createModule(.{...})` | 0.14→removed 0.15.1 |
| `build.zig.zon` `.name = "string"`, no `.fingerprint` | `.name = .ident`, mandatory `.fingerprint` | 0.14.0 |
| `@typeInfo(T)` with `.Int`/`.Struct` TitleCase tags | lowercase: `.int`, `.@"struct"`, `.@"enum"`, `.one` | 0.14.0 |

(Not a break, just a modernization: a `while (true) switch (state)` machine still
compiles, but labeled `switch` + `continue :label next` (0.14.0) reads better —
see [reference/idioms.md](reference/idioms.md).)

## Highest-leverage review checks

- **Allocators are passed explicitly, never global.** Allocating functions take
  `std.mem.Allocator` (idiomatically the first param); the caller owns the
  strategy. Pair `init(a, ...)` / `deinit(a)` / `freeX(a, ...)`. Use an
  `ArenaAllocator` for scoped bulk-free work, `DebugAllocator` in Debug/ReleaseSafe
  (leak detection), `std.heap.smp_allocator` for release.
  → [reference/memory.md](reference/memory.md)
- **`defer`/`errdefer` sit next to acquisition.** `const f = try open(); defer
  f.close();` on adjacent lines. `errdefer free(...)` right after a fallible alloc
  whose ownership transfers on success.
- **Named error sets at public boundaries; inferred `!T` for leaf functions.**
  Compose with `||`. Don't `catch unreachable` on genuinely fallible operations.
  → [reference/errors.md](reference/errors.md)
- **`[]const u8` for strings/read-only, `[]u8`/`[]T` slices over `[*]`/`*[N]`
  pointers** in parameters — slices keep bounds checking. Reserve `[:0]` sentinels
  for the C boundary. → [reference/idioms.md](reference/idioms.md)
- **`switch` over your own enum/tagged union has no `else`** — let exhaustiveness
  flag the day you add a variant. Use `union(enum)` for sum types/state.
- **Keep comptime sparse.** Reach for `comptime T: type` generics and `anytype`
  only when they earn it; metaprogramming for its own sake bloats compile time and
  wrecks error messages. (gp-wrapper's near-zero comptime is the right instinct.)
- **Tests are colocated and leak-checked.** A sibling `foo_test.zig` using
  `std.testing.allocator` (which fails on leak) and `expectError` for error paths.

## Tooling pass (before commit)

```sh
zig fmt .          # whitespace only — naming is a review job, not fmt's
zig build test     # colocated tests via the test step
zig build          # cross-compile targets via -Dtarget if relevant
```

`zig fmt` does **not** enforce naming — `camelCase` functions, `TitleCase` types
(including type-returning functions), `snake_case` variables/files are a reviewer
responsibility.

## What this skill is not

- Not a Zig tutorial. Not a restatement of `zig fmt`.
- Pinned to 0.15.2 deliberately — don't "upgrade" examples to 0.16 API while the
  project is held below it; flag deltas instead of rewriting.
- Prose it helps you write (doc comments) goes through **natural-writing**.
