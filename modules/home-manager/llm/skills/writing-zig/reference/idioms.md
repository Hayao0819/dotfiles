# Idioms

Reviewer-level calls plus the post-Writergate I/O API and comptime guidance.

## Slices over pointers in parameters

| Bad | Good | Why |
|---|---|---|
| `fn f(p: [*]u8, len: usize)` | `fn f(buf: []u8)` | a slice carries its length; bounds are checked |
| `fn f(p: *[N]u8)` for a buffer | `fn f(buf: []u8)` | callers pass `&arr` (coerces) or `arr[0..]` |
| `fn f(s: []u8)` for read-only data | `fn f(s: []const u8)` | string literals coerce; no forced mutable storage |
| `[:0]const u8` everywhere | plain `[]const u8` | reserve the sentinel for the C/FFI boundary |

## Tagged unions for state and sum types

```zig
const Event = union(enum) {
    connected: SessionId,
    message: []const u8,
    disconnected,
};

// switch with no else: a new variant becomes a compile error.
switch (event) {
    .connected => |id| onConnect(id),
    .message => |m| onMessage(m),
    .disconnected => onClose(),
}
```

Use `.{ ... }` anonymous struct literals and decl literals (`.empty`, `.init`,
`.default`) where the type is known. Prefer a normal struct; use `extern struct`
only for a C ABI and `packed struct` only for explicit bit/wire layout — not as a
"make it faster" reflex.

## Labeled switch for state machines (0.14+)

```zig
// Modern: continue to the next state by label — clearer and better-predicted
// than `while (true) switch (state)`.
state: switch (start) {
    .start => continue :state .running,
    .running => { ...; continue :state .done; },
    .done => break :state,
}
```

## The post-Writergate I/O API (0.15.1+)

The generic reader/writer is gone. Writers are concrete `std.Io.Writer` with a
caller-provided buffer; collect into memory with `std.Io.Writer.Allocating`:

```zig
// Build a string.
var aw: std.Io.Writer.Allocating = .init(allocator);
defer aw.deinit();
try aw.writer.print("{s}={d}", .{ key, value });
const result = aw.written();

// Direct stdout.
try std.fs.File.stdout().writeAll("done\n");

// A function that writes into any sink takes *std.Io.Writer.
fn writeUrlEncoded(w: *std.Io.Writer, s: []const u8) !void { ... }
```

## comptime — keep it sparse

```zig
// Generic via a comptime type param (memoized per type). Name T when the body
// needs it; reach for `anytype` only for "anything supporting these ops".
fn List(comptime T: type) type {
    return struct { items: []T };
}
```

`inline fn` / `inline for` unroll over comptime-known counts (e.g. struct
fields) — use sparingly, they bloat code. Reflection (`@typeInfo`, `@hasField`,
`@field`) uses **lowercase tags since 0.14**: `.int`, `.@"struct"`, `.@"enum"`,
`Pointer.Size.one` — pre-0.14 reflection won't compile. comptime hurts when it
inflates compile time, makes signatures opaque, or forces runtime-knowable data
into comptime. Sparse, pragmatic comptime is the idiom.
