# Tooling — what each catches and misses

Sanitizers find bugs only on **paths that execute** — pair them with fuzzing.
Static analysis is complementary, not redundant.

| Tool | Type | Catches | Misses / caveats |
|---|---|---|---|
| **ASan** (`-fsanitize=address`) | runtime | heap/stack/global OOB read+write, UAF, use-after-return (`detect_stack_use_after_return=1`), use-after-scope, double/invalid free, leaks (LSan) | executed paths only; ~2× slowdown + high RAM; misses uninitialized reads and most integer overflows; not for production |
| **MSan** (`-fsanitize=memory`) | runtime | use of uninitialized memory (branches, addresses, params) | must instrument **all** code incl. libc or false positives; Clang-only; ~3×; cannot combine with ASan |
| **UBSan** (`-fsanitize=undefined`) | runtime | signed-int overflow, shift, null, alignment, `bounds` (static-extent arrays), `object-size`, pointer-overflow | **unsigned overflow is not UB** — add `-fsanitize=integer`; `bounds` only for compile-time-known extents |
| **Valgrind/memcheck** | runtime (DBI) | UAF, invalid free, heap OOB, uninitialized reads, leaks — no recompile | ~10–50× slowdown; **weak on stack/global overflows** (no redzones there); executed paths only |
| **Clang Static Analyzer / scan-build** | static | NULL deref, UAF, leaks, some uninit/OOB via symbolic execution | path explosion → misses + false positives; limited interprocedural depth |
| **clang-tidy** | static (lint) | `clang-analyzer-*`, `bugprone-*`, `cert-*` (banned functions, `sizeof` misuse) | shallow data-flow |
| **cppcheck** | static | OOB, uninit, leaks, some integer issues; low FP design | misses complex interprocedural flows |
| **CodeQL** | static (taint) | source→sink taint for OOB/overflow/format-string with custom queries; whole-program | needs a build + query authoring; library-modeling gaps |
| **OSS-Fuzz / libFuzzer / AFL++** | dynamic | drives ASan/MSan/UBSan into deep paths at scale | needs harnesses + coverage; finds crashes, not classification |

## Recommended baseline

```sh
# One build for ASan+UBSan, driven by a fuzzer.
clang -fsanitize=address,undefined -fno-omit-frame-pointer -O1 -g harness.c -o h
# A separate MSan build (cannot combine with ASan) for uninitialized-memory coverage.
clang -fsanitize=memory -fno-omit-frame-pointer -O1 -g harness.c -o h_msan
```

Map each finding to **both** a CWE and the matching SEI CERT C rule (e.g. STR31-C
unbounded copy, ARR30-C OOB index, INT30-C unsigned overflow, MEM30-C UAF,
MEM34-C free of non-heap, FIO30-C format string) for cross-referencing.
