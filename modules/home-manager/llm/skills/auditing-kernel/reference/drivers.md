# Drivers & modules

Out-of-tree drivers are less reviewed and expose raw userspace entry points — the
richest target. Every surface here is an attacker-controlled boundary; apply the
[user-boundary.md](user-boundary.md) rules.

## ioctl handlers — the #1 attack surface

```c
static long my_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
{
    struct my_req req;

    // Validate the command against a known set (a missing default is a smell).
    switch (cmd) {
    case MY_IOC_SET:
        // arg is attacker-controlled: a value or a __user pointer.
        if (copy_from_user(&req, (void __user *)arg, sizeof req))
            return -EFAULT;
        // Bound EVERY field before use as index/size/offset.
        if (req.len > MY_MAX || req.off >= dev->size)
            return -EINVAL;
        ...
        break;
    default:
        return -ENOTTY;    // reject unknown commands
    }
}
```

Checklist:
- `cmd` validated against the known set; `default: return -ENOTTY`.
- The ioctl encoding (`_IO/_IOR/_IOW/_IOWR`, type, number, size) matches the struct
  and direction. `_IOC_SIZE` fits `_IOC_SIZEBITS` — 14 bits → max **16383** by
  default (some arches use 13 bits → 8191).
- Every field of the copied-in struct is range-checked before use.
- `compat_ioctl` present and consistent for 32-bit callers (`compat_ptr_ioctl`,
  `u64_to_user_ptr`); use `__u32`/`__u64` in ioctl structs, not `long`/pointers.
- Structs copied back are fully zeroed (no infoleak — see [memory-bugs.md](memory-bugs.md)).

Grep: `\.unlocked_ioctl|\.compat_ioctl|_IO(R|W|WR)?\(|switch *\(cmd\)`.

## Other input surfaces — same boundary rules

| Surface | Watch for / grep |
|---|---|
| sysfs `store` | `kstrtoX` not `simple_strtol`; bound the value; attr mode permissions. `DEVICE_ATTR\|__ATTR\|->store` |
| proc/debugfs `write` | debugfs often world-readable; writes are untrusted. `proc_create\|debugfs_create\|->write *=` |
| netlink | validate with `nla_parse` + a policy; unbounded attributes / missing policy are bugs. `nla_\|genl_\|nlmsg_` |
| char-dev `read`/`write` | `*ppos`, `count` are user-controlled; bound copies. `->read *=\|->write *=` |
| `mmap` | check `vm_pgoff`/length, set correct `vm_flags`/`pgprot`; mapping more than intended or RW where RO → leak/overwrite. `->mmap\|remap_pfn_range` |
| DMA | device-writable buffers are untrusted on return; validate device-provided lengths; descriptor-ring overflow. `dma_alloc\|dma_map` |
| module params | root-set at load, but still range-check. `module_param` |

## probe/remove and init/exit cleanup (CWE-401, CWE-416/415)

`probe`/`module_init` partial-failure must unwind in reverse with a `goto` ladder;
`remove`/`module_exit` must free exactly what was allocated. Common bugs:

- error path leaks or double-frees a resource.
- `remove()` frees an object still referenced by a timer/workqueue/IRQ that wasn't
  cancelled first → UAF. Order matters: `del_timer_sync` / `cancel_work_sync` /
  `free_irq` **before** freeing the object they touch.

```c
// Bad: free before stopping the worker that uses it.
kfree(dev->ctx);
cancel_work_sync(&dev->work);   // work may have already used freed ctx -> UAF

// Good: stop users first, then free.
cancel_work_sync(&dev->work);
kfree(dev->ctx);
```
