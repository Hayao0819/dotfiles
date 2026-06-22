---
name: auditing-kernel
description: >-
  Security audit of Linux kernel code and out-of-tree modules/drivers, with
  confidence-gated reporting to keep false positives low. Traces attacker input
  from userspace entry points (syscalls, ioctl, sysfs/proc/debugfs writes,
  netlink, char-dev, mmap) — and, for confidential-computing guests, from the
  untrusted host — to memory/refcount/locking/infoleak sinks. Covers UAF via
  refcount imbalance, the copy_to/from_user boundary, double-fetch TOCTOU,
  missing capability checks, integer-overflow allocations, ioctl handler review,
  and the TDX/SEV-SNP/SGX threat model. Use when reviewing kernel C, a driver/
  LKM, an ioctl handler, or enclave/attestation code for vulnerabilities.
---

# Auditing kernel code

A vulnerability-finding reviewer for Linux kernel and out-of-tree module/driver
code, built to **report only what is attacker-reachable and exploitable** — not
to pattern-match. The organizing frame is the **trust boundary**: anything
crossing from userspace into the kernel (or, in a confidential-computing guest,
from the host) is attacker-controlled and must be traced to the operations it
reaches.

## Methodology (do this before flagging anything)

1. **Map the trust boundary.** Enumerate every attacker-reachable entry point:
   syscalls, `ioctl`/`unlocked_ioctl`/`compat_ioctl`, sysfs `store`, proc/debugfs
   `write`, netlink ops, char-dev `read`/`write`, `mmap`. For CoCo guests add
   host inputs (shared memory, MMIO, virtio rings). Mark all of these inputs
   **attacker-controlled**. → [reference/user-boundary.md](reference/user-boundary.md)
2. **Determine reachability and privilege.** Is the device node / sysfs attr
   reachable by an *unprivileged* user (mode bits, udev)? Is there a
   `capable()`/`ns_capable()` gate? Root-only or correctly capability-gated paths
   are lower severity and often **not vulnerabilities** (intended privileged
   behavior).
3. **Trace input to sinks.** Follow each attacker-controlled value to allocators
   (size overflow), array indices (OOB), copy helpers (length mismatch / missing
   `access_ok`), free sites (UAF/double-free), locks (race/deadlock), and
   `copy_to_user` (infoleak). Note any double-fetch.
4. **Confidence-gate the finding** (below). Report HIGH only.

## Confidence gate — report HIGH only

| Level | Criteria | Action |
|---|---|---|
| **HIGH** | attacker-reachable at the stated privilege **+** attacker controls the input **+** a concrete unsafe consequence (corruption, infoleak, priv-esc) | report with severity |
| **MEDIUM** | unsafe pattern but reachability or input-control unclear | note as "needs verification" |
| **LOW** | theoretical, or neutralized by a present check / hardening config | do not report |

Severity by primitive: arbitrary write / UAF (critical) > controlled OOB write >
OOB read / infoleak (often KASLR-only) > NULL-deref / leak DoS. Weight up for
unprivileged-local reach, down for root-only.

## How to read this skill

| Open this | When the code involves |
|---|---|
| [reference/memory-bugs.md](reference/memory-bugs.md) | alloc/free/copy, refcounts, indices, struct copy-out |
| [reference/user-boundary.md](reference/user-boundary.md) | `__user` pointers, `copy_*`, capability checks, double-fetch |
| [reference/concurrency.md](reference/concurrency.md) | locks, RCU, shared state, error-path unlock |
| [reference/drivers.md](reference/drivers.md) | ioctl, sysfs/proc/netlink/char-dev, mmap, probe/remove |
| [reference/tee.md](reference/tee.md) | TDX/SEV-SNP guest, SGX enclave, attestation/IMA/RTMR |

## The highest-yield checks

- **UAF via refcount imbalance** is the dominant exploitable bug. For every
  `get`/`kref_get`, find the matching `put` on **every** path including each
  error `goto`. A `put` too many → premature free → later deref = UAF. Prefer
  `refcount_t` (saturates) over `atomic_t` for refcounts. → [memory-bugs.md](reference/memory-bugs.md)
- **The `__user` boundary.** A `__user` pointer is never dereferenced directly —
  only via `copy_from_user`/`get_user` (which embed `access_ok`). Check the
  return value (`if (copy_from_user(...)) return -EFAULT;`). → [user-boundary.md](reference/user-boundary.md)
- **Double-fetch TOCTOU.** Reading the same `__user` region twice (header then
  body) lets a concurrent thread change it between reads. Copy once into the
  kernel, validate the *kernel* copy. → [user-boundary.md](reference/user-boundary.md)
- **Integer overflow before allocation.** User size/count into `kmalloc(n *
  size)` wraps → undersized buffer → heap overflow. Use `kmalloc_array`/`kcalloc`/
  `struct_size`/`check_*_overflow`. → [memory-bugs.md](reference/memory-bugs.md)
- **Uninitialized copy-out.** A struct with padding populated field-by-field then
  `copy_to_user`'d leaks kernel memory. `memset(&s, 0, sizeof s)` first. → [memory-bugs.md](reference/memory-bugs.md)
- **ioctl handlers** are the #1 driver attack surface — validate `cmd` against a
  known set and every field of `arg` before use. → [drivers.md](reference/drivers.md)

## Do NOT flag (false-positive guards)

- A path gated by a **correct** `capable()`/`ns_capable(CAP_*)` check — privileged
  by intent (only a vuln if the *wrong* capability/namespace is checked).
- An entry point **root-only** by device-node mode / udev / `0600` sysfs attr and
  unreachable by unprivileged users.
- `kfree(NULL)` / `kvfree(NULL)` — safe, not a double-free.
- "missing `access_ok`" on a `copy_from_user`/`get_user` — the accessor *contains*
  `access_ok`; only raw `__user` derefs or `__copy_*`-without-check are bugs.
- A `memset`/`= {}` that already zeroes padding before copy-out — no infoleak.
- An index/size **bounded earlier** in the function — trace the full path first.
- Mitigation-neutralized bugs (infoleak under `INIT_ON_ALLOC`, refcount-UAF under
  saturating `refcount_t`) — **but** confirm the target `.config`: out-of-tree and
  vendor kernels often ship KSPP hardening off.

## Tooling (run these; they catch what review misses)

| Tool | Catches |
|---|---|
| **Sparse** | `__user`/`__iomem` address-space confusion, endianness |
| **Smatch** | NULL deref, locking imbalance/ABBA, error-path leaks, user-data-to-sink tracking |
| **Coccinelle** (`make coccicheck`) | double-free, missing checks, API misuse patterns |
| **syzkaller/syzbot** | coverage-guided syscall fuzzing surfacing the below |
| **KASAN / KCSAN / KMSAN / UBSAN** | OOB+UAF+double-free / data races / uninit use / UB+bounds |
| **lockdep** (`PROVE_LOCKING`) | lock-ordering deadlocks (ABBA) |

## What this skill is not

- Not a kernel-coding tutorial and not a restatement of `checkpatch`.
- Not a guarantee — pair static review with the sanitizers/fuzzers above.
- Reports go through **natural-writing**: each finding states the entry point, the
  attacker-controlled input, the sink, the primitive, and a CWE.
