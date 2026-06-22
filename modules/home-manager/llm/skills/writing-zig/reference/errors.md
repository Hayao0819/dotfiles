# Errors

Zig errors are values in an error set, returned as an error union `E!T` and
propagated with `try`. The reviewer-level decisions are: named vs inferred error
sets, where to `catch`, and never papering over a real failure with
`catch unreachable`.

## Named sets at boundaries, inferred inside

```zig
// Public API: a named, composed error set callers can switch on exhaustively.
pub const Error = error{ HttpFailed, EmptyResponse, NoGateways } ||
    std.http.Client.RequestError ||
    std.mem.Allocator.Error ||
    std.Io.Writer.Error;

pub fn fetch(allocator: std.mem.Allocator, url: []const u8) Error![]u8 { ... }

// Internal/leaf function: an inferred `!T` set is fine and refactor-friendly.
fn parseLine(line: []const u8) !Token { ... }
```

Inferred (`!T`) is convenient but silently widens and can't be named — so use an
explicit `error{...}!T` at public boundaries and anywhere a caller `switch`es over
the failures. (gp-wrapper composes named sets with `||` at every module boundary;
mirror that.)

## try, catch, errdefer

```zig
// `try` propagates — and preserves the error return trace.
const body = try fetch(a, url);

// `catch` handles or remaps at a boundary.
const body = fetch(a, url) catch |err| switch (err) {
    error.EmptyResponse => return error.NoGateways, // remap
    else => return err,                              // re-propagate the rest
};
```

Prefer `try` over catch-and-recreate so the error return trace survives. Use
`errdefer` (not `defer`) for rollback that should happen only on the error path —
see [memory.md](memory.md).

## unreachable

`unreachable` asserts a branch can't happen. It **panics in Debug/ReleaseSafe and
is UB in ReleaseFast** — so it's for provable invariants and exhaustive-switch
`else` arms only:

```zig
// OK: the switch is exhaustive, so the else is genuinely unreachable.
const name = switch (tag) {
    .a => "a",
    .b => "b",
};

// Bad: catch unreachable on a genuinely fallible op — a real error becomes UB
// in release. Handle it or `try` it.
const f = std.fs.cwd().openFile(path, .{}) catch unreachable; // no
```

Never `catch unreachable` on I/O, allocation, or parsing — anything that can
actually fail with bad input or environment.
