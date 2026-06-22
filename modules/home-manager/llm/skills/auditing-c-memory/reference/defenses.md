# Build hardening to verify

When auditing a build, check these are on — and calibrate severity by what's
present. Source of truth: the OpenSSF Compiler Options Hardening Guide for C/C++.

| Defense | Flag(s) | What it buys |
|---|---|---|
| Fortified libc | `-D_FORTIFY_SOURCE=3` (with `-O1`+) | compile- and run-time bounds checks on `memcpy`/`strcpy`/`sprintf`/… **Level 3** (GCC 12 / glibc ≥2.34) handles *non-constant* sizes via `__builtin_dynamic_object_size` — far wider coverage than level 2 |
| Stack canary | `-fstack-protector-strong` | detects contiguous stack overflows of the return address; "strong" covers many more frames than the default |
| Stack clash | `-fstack-clash-protection` | probes large/VLA stack growth; defeats jumping over the guard page |
| CFI | `-fcf-protection=full` (x86 CET), `-mbranch-protection=standard` (AArch64 BTI/PAC) | hardware control-flow integrity vs ROP/JOP |
| ASLR | `-fPIE -pie` | full ASLR of the main image |
| RELRO | `-Wl,-z,relro -Wl,-z,now` | GOT read-only after load → blocks GOT overwrite |
| NX stack | `-Wl,-z,noexecstack` | non-executable stack (W^X) |
| STL asserts | `-D_GLIBCXX_ASSERTIONS` | bounds/precondition checks in libstdc++ containers |
| Auto-init | `-ftrivial-auto-var-init=zero` | zero-inits automatics → kills many uninitialized-use leaks |
| Non-null | `__attribute__((nonnull))` / `-Wnonnull` | flags NULL passed to non-null params |
| Warnings | `-Wall -Wextra -Wconversion -Wformat=2 -Werror=format-security -Wimplicit-fallthrough` | `-Wconversion` catches truncation/sign feeding sizes; `format-security` makes CWE-134 a build error |

## Calibration notes

- A bug largely neutralized by a present mitigation (an uninitialized-memory leak
  under `-ftrivial-auto-var-init=zero`, a stack overflow caught by a canary before
  exploitation) is lower severity — but say so explicitly, and confirm the flag is
  actually in the build (embedded/vendor builds often omit them).
- `_FORTIFY_SOURCE` only fortifies calls where the compiler can reason about the
  destination size; an attacker-controlled `memcpy` into a heap buffer of dynamic
  size may still be unprotected even with level 3 — don't assume FORTIFY closes a
  finding without checking.
- **Annex K** (`memcpy_s`, `strcpy_s`, …): treat as informational, not a control.
  WG14 N1967 (2015) recommended removal over near-zero conforming adoption; the
  committee instead **retained it as optional in C23** (`__STDC_LIB_EXT1__`), and
  it remains effectively unadopted. Don't flag the *absence* of `_s` functions;
  `_FORTIFY_SOURCE=3` is the practical equivalent.
- Note `strlcpy`/`strlcat` landed in **glibc 2.38** (Aug 2023), so on current
  glibc they're available — only flag their absence when targeting musl or
  pre-2.38.
