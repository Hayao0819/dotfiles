# Memory & allocators

Zig has no global allocator and no hidden allocation. Any function that allocates
takes a `std.mem.Allocator` — idiomatically the first parameter — and the caller
chooses the strategy. This is the language's central discipline.

## Pass it, pair it

```zig
// init takes the allocator; deinit and freeX take it back. Ownership is documented.
pub fn init(allocator: std.mem.Allocator, n: usize) !Buffer {
    const data = try allocator.alloc(u8, n);
    errdefer allocator.free(data); // freed if a later step in init fails
    return .{ .data = data };
}

pub fn deinit(self: *Buffer, allocator: std.mem.Allocator) void {
    allocator.free(self.data);
}
```

`defer`/`errdefer` run LIFO and belong right next to the acquisition:

```zig
const file = try std.fs.cwd().openFile(path, .{});
defer file.close();           // always runs on scope exit

const buf = try allocator.alloc(u8, len);
errdefer allocator.free(buf); // runs only if a later `try` fails; ownership transfers on success
```

## Choosing an allocator

| Allocator | Use for |
|---|---|
| `DebugAllocator(.{})` | Debug / ReleaseSafe — detects leaks and double-frees. `GeneralPurposeAllocator` is the **deprecated** alias (renamed in 0.14); gp-wrapper still uses the old name in main/cli, so prefer `DebugAllocator` in new code but don't flag the existing `GeneralPurposeAllocator` usage. |
| `std.heap.smp_allocator` | the recommended release allocator for ReleaseFast/ReleaseSmall, multi-threaded |
| `ArenaAllocator` | scoped work freed all at once (a request, a parse) — `deinit()` frees everything |
| `FixedBufferAllocator` | deterministic, no-heap, fixed budget |
| `page_allocator` | only as a backing allocator for the above |
| `c_allocator` | at the C/FFI boundary (needs `-lc`) |

Canonical pick: `DebugAllocator` in Debug/ReleaseSafe, `smp_allocator` in release.
An `ArenaAllocator` over scoped work is the common ergonomic win — allocate freely,
free once.

```zig
var arena = std.heap.ArenaAllocator.init(gpa);
defer arena.deinit();          // frees everything allocated below
const a = arena.allocator();
// ... many small allocations for this request, no individual frees ...
```

## Leak-checked tests

`std.testing.allocator` fails the test if anything it handed out isn't freed —
use it in every test that allocates:

```zig
test "parse frees its scratch" {
    const a = std.testing.allocator;
    const parsed = try parse(a, input);
    defer parsed.deinit(a);      // forget this and the test fails — that's the point
    try std.testing.expectEqual(@as(usize, 3), parsed.count);
}
```

`std.testing.checkAllAllocationFailures` injects OOM at each allocation point
to verify your `errdefer` cleanup is correct.
