# The userspace boundary

Where most exploitable driver/syscall bugs live. The kernel must never dereference
a `__user` pointer directly — it uses accessors that embed `access_ok()` range
checks. Treat everything arriving from userspace as attacker-controlled.

## Missing/incorrect copy helpers, unchecked `__user` pointers (CWE-822, CWE-787/125)

```c
// Bad: dereferencing a __user pointer directly, or memcpy from it.
val = *uptr;                    // uptr is __user — direct deref
memcpy(kbuf, uptr, n);          // bypasses access_ok

// Good
if (get_user(val, uptr)) return -EFAULT;
if (copy_from_user(kbuf, uptr, n)) return -EFAULT;
kbuf = memdup_user(uptr, n);    // alloc+copy idiom; check IS_ERR
```

Check return values: `copy_from_user` returns *bytes not copied* — the correct
test is `if (copy_from_user(...)) return -EFAULT;`. Ignoring it, or a `>0`/`<0`
confusion, is a bug. Sparse enforces `__user` annotations statically.

Grep:
```
grep -nE '__user'                          # then confirm each is only touched via accessors
grep -nE 'copy_(from|to)_user|get_user|put_user|memdup_user|strndup_user'
```

(Do **not** flag a `copy_from_user`/`get_user` for "missing access_ok" — the
accessor contains it. Only raw `__user` derefs and `__copy_*`-without-check are
bugs.)

## Double-fetch / TOCTOU on user pointers (CWE-367)

Reading the same `__user` region twice — once for a length/header, again for the
body — and assuming it's unchanged. A concurrent userspace thread mutates it
between fetches; the validated size no longer matches the copied size → OOB or a
logic bypass.

```c
// Bad: re-reads hdr.len from userspace after validating it.
get_user(len, &uhdr->len);
if (len > MAX) return -EINVAL;
copy_from_user(buf, uhdr->data, len);    // len re-fetched from user memory? double-fetch

// Good: copy the whole header once into the kernel, validate the kernel copy,
// never re-read a field from userspace.
if (copy_from_user(&hdr, uhdr, sizeof hdr)) return -EFAULT;
if (hdr.len > MAX) return -EINVAL;
if (copy_from_user(buf, uhdr->data, hdr.len)) return -EFAULT;
```

Grep for two or more `copy_from_user`/`get_user` from the same user pointer in one
handler and check whether a validated field is re-fetched.

## Missing capability checks (CWE-862, CWE-863)

A privileged operation reachable without `capable()`/`ns_capable()` is a
privilege-escalation bug. A check against the wrong namespace (`capable()` where
`ns_capable()` is needed, or vice versa) is CWE-863.

```c
// Bad: a global-state mutation with no guard.
case CMD_SET_GLOBAL:
        global_policy = arg;    // any unprivileged caller can do this

// Good
case CMD_SET_GLOBAL:
        if (!capable(CAP_SYS_ADMIN)) return -EPERM;
        global_policy = arg;
```

Enumerate every ioctl/write/netlink op that mutates global state, allocates large
memory, or touches hardware; confirm a correct capability check gates it. A
*present, correct* check usually means the path is intended-privileged — that's
not a vuln (see SKILL.md do-not-flag).

Grep: `grep -nE 'capable\(|ns_capable\(|CAP_[A-Z_]+'` and check the gate exists at
each privileged entry.
