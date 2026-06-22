# Concurrency

Race conditions and locking bugs are exploitable when an attacker can win the race
(e.g. two threads hammering an ioctl). Tag with CWE-362 (race), CWE-667 (improper
locking), CWE-833 (deadlock).

## Data races on shared state (CWE-362)

A shared object mutated without a lock, or under inconsistent locks. KCSAN finds
these dynamically; statically, check that every access to lock-protected data is
held under the same lock.

```c
// Bad: check-then-act on shared state without holding the lock across both.
if (obj->state == READY)        // another thread can change state here
        obj->buf = use(obj);    // TOCTOU on shared state

// Good: hold the lock across the check and the action.
mutex_lock(&obj->lock);
if (obj->state == READY)
        obj->buf = use(obj);
mutex_unlock(&obj->lock);
```

## Missing locks / inconsistent order → ABBA deadlock (CWE-833)

Two locks acquired in opposite orders on two paths deadlock. Lock order must be
globally consistent. `lockdep` (`CONFIG_PROVE_LOCKING`) catches this at runtime;
Smatch has a static locking check.

The error-path variant: a `goto` that skips an `unlock` deadlocks on the error
path. Confirm every lock is released on **every** exit, including each `goto`.

```c
// Bad: error path returns without unlocking.
spin_lock(&l);
if (bad) return -EINVAL;        // l never released -> deadlock
spin_unlock(&l);

// Good
spin_lock(&l);
if (bad) { ret = -EINVAL; goto out; }
...
out:
        spin_unlock(&l);
        return ret;
```

## RCU misuse

Dereferencing an RCU-protected pointer outside `rcu_read_lock()`, or freeing
without `synchronize_rcu()`/`call_rcu()` (UAF). Check pairing:

```
grep -nE 'rcu_dereference|list_for_each_entry_rcu'   # must be under rcu_read_lock
grep -nE 'call_rcu|synchronize_rcu|kfree_rcu'        # free path for RCU objects
```

## refcount_t vs atomic_t

A refcount implemented with `atomic_t` loses the saturation protection that turns
an underflow into a WARN instead of a wrap-to-zero UAF. Flag `atomic_*` used as a
reference count and recommend `refcount_t`. See
[memory-bugs.md](memory-bugs.md) for the UAF chain.

Audit method: for each lock, confirm every access to the data it protects holds
it; for each object, confirm the get/put and RCU grace-period rules; check error/
goto paths release locks and balance refcounts.
