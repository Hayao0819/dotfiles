---
name: auditing-c-memory
description: >-
  Security audit of memory-safety vulnerabilities in C/C++ (userland/systems,
  not kernel), with confidence-gated reporting to keep false positives low.
  Taint-traces untrusted input (argv, env, files, network, stdin) to memory
  sinks (copy length, array index, allocation size, format string) and reports
  only when input is attacker-controlled AND reaches the sink AND bounds aren't
  enforced. Covers buffer overflow, use-after-free, double-free, OOB read,
  integer overflow into undersized alloc, format string, the dangerous-function
  table, hardening flags to verify, and the ASan/UBSan/MSan/fuzzing toolchain.
  Covers userland/systems C and the SGX enclave/host (ECALL/OCALL) pointer
  boundary. Use when reviewing C/C++ for memory-corruption bugs. Kernel code →
  auditing-kernel.
---

# Auditing C memory safety

A vulnerability-finding reviewer for memory-corruption bugs in C/C++, built to
**report only attacker-reachable, exploitable issues** — not to flag every
`strcpy`. Memory-safety bugs stay top-tier in the CWE Top 25 (2025 list:
out-of-bounds write #5, use-after-free #7, out-of-bounds read #8; integer
overflow CWE-190 fell off the Top 25 but is still a real class), so the value is
in separating the real ones from the bounded/validated/constant ones.

**Enclave/host boundary (SGX):** much of this engineer's C is SGX-enclave code,
where the highest-value bugs live at the ECALL/OCALL boundary — host-supplied
pointers and lengths crossing into the enclave are a taint source exactly like
the kernel's `__user`. Validate that a host buffer lies fully outside the enclave
(`sgx_is_outside_enclave`) before copying it in, copy once into enclave memory,
and beware TOCTOU on host memory between check and use. (The enclave *runtime*
re-entrancy class — SmashEx — is in **auditing-kernel**'s TEE reference.)

For kernel and driver code, use **auditing-kernel** (the `__user` boundary,
refcounts, capability model). For userland/host-side C (incl. SGX *host* apps),
this is the right skill.

## Methodology — taint, then gate

Trace each value from an untrusted **source** to a memory **sink**, and report
only when all three gates hold.

**Sources (untrusted input):** `argv`/`argc`, `getenv`, `read`/`recv`/`recvfrom`,
`fread`/`fgets`/`getline` on attacker files, `scanf` on stdin, socket/IPC buffers,
deserialized fields, `mmap`'d files.

**Sinks (memory operations):** copy length (`memcpy`/`strcpy`/`sprintf`/`read`),
index (`arr[i]`, `p + i`), allocation size (`malloc`/`calloc`/`realloc`/`alloca`,
VLA dim), format-string argument.

**The three-gate rule — report only when ALL hold:**
1. **Tainted** — the length/index/size/format value is attacker-controlled (trace
   it back to a source; constants and program-internal values are not tainted).
2. **Reaches the sink** — a real data-flow path connects source → sink (account
   for clamping/sanitization on the way).
3. **Bounds not enforced** — no `if (len <= cap)`, no `min()`, no validated
   upstream invariant between source and sink.

If any gate fails, downgrade or drop.

## Confidence gate

| Level | Criteria | Action |
|---|---|---|
| **HIGH** | all three gates met + a write or exfiltrating over-read primitive | report with severity + CWE |
| **MEDIUM** | tainted-and-reaches, but bounds status unclear | note "needs verification" |
| **LOW** | pattern present but likely bounded/validated/constant | do not report |

Severity = (write > read) × (attacker controls *what*/*how much* > only *that* it
happens) × (reachable pre-auth/parser > post-auth). An attacker-controlled-length
`memcpy` writing past a heap buffer is critical; a one-byte bounded over-read is low.

## How to read this skill

| Open this | When |
|---|---|
| [reference/vuln-classes.md](reference/vuln-classes.md) | the bug classes + the dangerous-function table, CWE-anchored |
| [reference/defenses.md](reference/defenses.md) | FORTIFY/canaries/ASLR/RELRO and other build hardening to verify |
| [reference/tooling.md](reference/tooling.md) | ASan/UBSan/MSan/Valgrind/static analysis/fuzzing — what each catches |

## The classes (full detail in vuln-classes.md)

- **Buffer overflow** (CWE-787 write / CWE-125 read / CWE-120): unbounded
  `strcpy`/`strcat`/`sprintf`/`gets`, `memcpy` with attacker-controlled length,
  off-by-one (`<=` loop, `buf[strlen(s)]` with no `+1`).
- **Use-after-free / double-free** (CWE-416 / CWE-415): dangling use, free on an
  error path then use in cleanup, use-after-realloc, double-free on a `goto`.
- **OOB read** (CWE-125): respond with an attacker-claimed length (Heartbleed),
  `strlen`/`strcmp` on a non-NUL-terminated buffer.
- **Integer overflow → undersized alloc** (CWE-190/191): `malloc(n * size)` wrap,
  `len - 1` underflow, narrowing cast on a size.
- **Format string** (CWE-134): `printf(user_input)`.
- **NULL deref / uninitialized use / type confusion** (CWE-476/457/843).

## Dangerous-function quick table (detail in vuln-classes.md)

| Function | Risk | Replacement / gotcha |
|---|---|---|
| `gets` | unbounded (removed in C11) | `fgets` |
| `strcpy`/`strcat`/`sprintf` | unbounded | `snprintf`/`strlcpy`/`strlcat` |
| `strncpy` | does **not** NUL-terminate if src ≥ n | `snprintf`; or set `d[n-1]=0` — its non-termination causes later OOB reads |
| `snprintf` | safe size-wise | **returns the length it *would* have written** — check for truncation |
| `scanf("%s")` | unbounded | width-limit `%63s` |
| `memcpy`/`memmove` | trusts `len` | bound `len <= cap` first; `memcpy` UB on overlap |
| `alloca`/VLA | unchecked stack growth | heap `malloc`, or cap the size |

## Do NOT flag (false-positive guards)

- A `memcpy`/index with a **compile-time-constant** size, or a size provably
  `<= sizeof(dst)`.
- A length/index **validated upstream** (clamped, `min()`'d, range-checked) — follow
  the path, don't pattern-match the sink alone.
- Input that is program-internal/trusted (not reachable from a source).
- `strncpy`/`snprintf` truncation that is intended **and the return is handled** —
  a logic concern, not memory corruption.
- Absence of Annex K `*_s` functions — they're effectively unadopted (WG14 N1967
  recommends removing them); `_FORTIFY_SOURCE=3` is the practical control.
- A NULL-deref reachable only via an internal invariant that can't be NULL — and
  most NULL derefs are DoS, not RCE; calibrate severity down.

## Tooling (run these; sanitizers find what review misses on executed paths)

```sh
# Build the test/fuzz config with sanitizers, drive it with a fuzzer.
clang -fsanitize=address,undefined -fno-omit-frame-pointer -O1 ...   # ASan+UBSan
clang -fsanitize=memory ...        # MSan: uninitialized reads (separate build; not with ASan)
valgrind --tool=memcheck ./prog    # no recompile; weak on stack/global overflows
scan-build make ; clang-tidy ; cppcheck ; codeql   # static, complementary
# OSS-Fuzz / libFuzzer / AFL++ to reach deep paths
```

Sanitizers only catch bugs on **paths that execute** — pair them with fuzzing;
treat static analysis as complementary. → [reference/tooling.md](reference/tooling.md)

## What this skill is not

- Not a C tutorial. Not a guarantee — pair review with sanitizers + fuzzing.
- Not kernel auditing — that's **auditing-kernel**.
- Findings go through **natural-writing**: state the source, the sink, why bounds
  aren't enforced, the primitive, and a CWE.
