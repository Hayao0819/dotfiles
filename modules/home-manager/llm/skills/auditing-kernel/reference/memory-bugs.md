# Memory bugs

The exploitable classes, with grep patterns and bad/good pairs. Tag findings with
the CWE.

## UAF via refcount imbalance (CWE-416, CWE-911)

Most kernel UAFs are not "free then use one line later" — they're refcount
imbalances. A `put` too many drops the count to zero while a reference is still
live; the object is freed; a later dereference is a UAF.

```c
// Bad: error path takes a ref but jumps past the put — or puts one too many.
obj = lookup_get(id);          // refcount held
if (copy_from_user(&arg, uarg, sizeof(arg)))
        return -EFAULT;        // leaked ref here; or a second put below -> underflow -> UAF
put(obj);

// Good: single put on a unified error ladder.
obj = lookup_get(id);
if (copy_from_user(&arg, uarg, sizeof(arg))) {
        ret = -EFAULT;
        goto out_put;
}
...
out_put:
        put(obj);
        return ret;
```

Audit method: build a get/put ledger per object across the whole function,
including every `goto` target. `kref_get`/`kref_put` must balance; the release
callback runs at zero. Prefer `refcount_t` (saturates and WARNs on
underflow/overflow) over `atomic_t` used as a refcount — flag `atomic_*` on
anything named like a refcount.

Grep:
```
grep -nE '\b(kref_get|kref_put|get_|put_|_get\(|_put\()'
grep -nE 'atomic_(inc|dec|add|sub).*ref'   # atomic_t as a refcount = suspicious
```

## Double-free (CWE-415)

Usually an error path where a helper already freed and the caller frees again, or
a list element freed without being unlinked first.

```c
if (parse(p) < 0) { kfree(p); goto err; }
...
err:
        kfree(p);              // double-free if reached after the first kfree
```

Good practice: NULL the pointer after free if reachable again; one free site per
resource via a `goto` ladder. (`kfree(NULL)` is safe — don't flag it.)

## OOB on slab/heap/stack (CWE-787 write, CWE-125 read, CWE-122/121)

```c
// Bad: multiply inside the allocator arg can overflow (see integer section).
buf = kmalloc(n * size, GFP_KERNEL);
// Bad: attacker-controlled index with no bound.
table[user_idx] = val;

// Good
buf = kmalloc_array(n, size, GFP_KERNEL);
if (user_idx >= ARRAY_SIZE(table)) return -EINVAL;
```

Grep: `kmalloc\([^,]*\*`, `memcpy|memmove|copy_(to|from)_user`, array indices
named `idx`/`len`/`count`/`user`.

## Uninitialized copy-out / infoleak (CWE-908, CWE-200)

A struct with implicit padding, populated field-by-field then copied to userspace,
leaks the padding bytes (defeats KASLR).

```c
// Bad: padding between/after members is never written.
struct foo f;
f.a = x; f.b = y;
copy_to_user(uptr, &f, sizeof(f));

// Good: zero the whole struct first.
struct foo f = {};            // or memset(&f, 0, sizeof f);
f.a = x; f.b = y;
copy_to_user(uptr, &f, sizeof(f));
```

Grep: every `copy_to_user`/`put_user`/`nla_put`/`skb_put` of a struct → confirm
full zero-init, especially structs mixing `__u8` with wider members. (A present
`memset`/`= {}` means no infoleak — don't flag.)

## Integer overflow → undersized allocation (CWE-190, CWE-191, CWE-194/197)

User length/count multiplied or added before an allocation or copy; overflow → tiny
buffer → full-size copy → heap overflow. Siblings: truncation into a narrower type,
signed/unsigned confusion (negative length becomes huge unsigned).

```c
// Bad: len * elem can still overflow even after an upper-bound check on len alone.
if (len > MAX) return -EINVAL;
buf = kmalloc(len * elem, GFP_KERNEL);

// Good
buf = kmalloc_array(len, elem, GFP_KERNEL);
// or: if (check_mul_overflow(len, elem, &sz)) return -EOVERFLOW;
//     buf = kmalloc(sz, GFP_KERNEL);
// flex member: kzalloc(struct_size(h, item, n), GFP_KERNEL);
```

Flag `int`/`short`/`u16` holding a user size, and comparisons that permit a
negative length. VLAs are banned in-tree — flag non-constant local array
dimensions and `alloca`.
