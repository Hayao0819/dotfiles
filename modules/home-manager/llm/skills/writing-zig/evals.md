# Evals — writing-zig

Run each fresh with the skill available and disabled; check trigger + output.
Examples assume Zig 0.15.2.

## 1. Allocator discipline

**Query:** "Review this function." (paste a function that allocates but doesn't
take an allocator, or one that allocates without an `errdefer` free on the error
path)

**Expected behavior:**
- Flags the missing explicit allocator parameter (no global allocation in Zig).
- Recommends `errdefer allocator.free(...)` adjacent to the fallible alloc.
- Suggests `std.testing.allocator` to leak-check the test.

## 2. Version-break detection

**Query:** "This won't compile on my Zig, what's wrong?" (paste code using
`std.ArrayList(T).init(a)` + `list.append(x)` and `std.io.getStdOut().writer()`)

**Expected behavior:**
- Identifies the unmanaged ArrayList change: `.empty` + `list.append(a, x)`.
- Identifies Writergate: `std.fs.File.stdout().writeAll(...)` /
  `std.Io.Writer.Allocating`.
- Attributes both to 0.15.1 and doesn't give pre-0.14 advice.

## 3. Error / switch idioms

**Query:** "Anything to improve?" (paste a `switch` over a tagged union with an
`else => {}`, and a `catch unreachable` on a file open)

**Expected behavior:**
- Recommends dropping the `else` for exhaustiveness.
- Flags `catch unreachable` on fallible I/O as UB-in-release; handle or `try`.
- May note named error sets at the boundary.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: the skill should stay pinned to 0.15.2 idioms and *flag* 0.16
  deltas, not silently rewrite to 0.16.
- Should not fire for non-Zig files.
