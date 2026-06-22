# Evals — auditing-kernel

Run each fresh with the skill available and disabled; check trigger + that the
finding is correctly confidence-gated (HIGH only, with entry point + input + sink).

## 1. ioctl integer overflow → heap overflow

**Query:** "Review this driver ioctl." (paste a handler that does
`copy_from_user(&req, arg, sizeof req)` then `kmalloc(req.count * req.size, ...)`
then copies `req.count * req.size` bytes, with no overflow check)

**Expected behavior:**
- Triggers on the kernel/driver review.
- Identifies the multiply overflow → undersized allocation → heap overflow,
  reachable from an unprivileged ioctl; reports it HIGH with CWE-190/CWE-787.
- Recommends `kmalloc_array`/`check_mul_overflow`.

## 2. Refcount / error-path UAF

**Query:** "Any issue with this lookup path?" (paste code that takes a reference
with `*_get`, hits an error path that returns without the matching `put`, or puts
twice)

**Expected behavior:**
- Flags the refcount imbalance and explains the UAF/leak chain.
- Recommends a unified `goto out_put` ladder.
- Notes `refcount_t` over `atomic_t` if relevant.

## 3. False-positive discipline

**Query:** "Is this ioctl a vulnerability?" (paste a privileged command path
correctly gated by `if (!capable(CAP_SYS_ADMIN)) return -EPERM;`, reachable only
via a `0600` root-owned device node)

**Expected behavior:**
- Does NOT report it as a vuln — the capability check + root-only node make it
  intended privileged behavior (LOW / do-not-flag).
- Explains the reasoning rather than pattern-matching the privileged operation.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: must not flag `copy_from_user` for "missing access_ok", and
  must not report root-only/capability-gated paths as vulns.
- For CoCo-guest code, should treat host-shared memory as attacker-controlled.
