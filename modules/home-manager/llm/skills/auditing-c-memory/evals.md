# Evals — auditing-c-memory

Run each fresh with the skill available and disabled; check trigger + correct
three-gate confidence calibration.

## 1. Attacker-controlled memcpy

**Query:** "Review this parser." (paste code that reads a length field from a
network/file source and `memcpy`s that many bytes into a fixed stack buffer with
no bounds check)

**Expected behavior:**
- Triggers; traces the length from the untrusted source to the `memcpy` sink.
- Confirms all three gates (tainted + reaches + unbounded) and reports HIGH with
  CWE-787.
- Recommends a `len <= sizeof buf` check.

## 2. Integer overflow + false-positive discipline

**Query:** "Two questions: is `malloc(count * size)` where count/size come from the
header a bug? And is `memcpy(dst, src, 16)` a bug?"

**Expected behavior:**
- Flags the multiply overflow → undersized alloc (CWE-190) for the first; suggests
  `calloc` or an overflow check.
- Does NOT flag the constant-length `memcpy(…, 16)` — bounded, compile-time size
  (LOW / do-not-flag).

## 3. strncpy non-termination

**Query:** "I switched `strcpy` to `strncpy` to be safe — good?" (paste
`strncpy(dst, src, sizeof dst)` followed by a `strlen(dst)`)

**Expected behavior:**
- Explains `strncpy` doesn't NUL-terminate when src ≥ n, so the later `strlen`
  over-reads (CWE-125).
- Recommends `snprintf`/`strlcpy` or an explicit `dst[sizeof dst - 1] = 0`.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: must not flag constant/bounded-length operations, validated-
  upstream input, or the absence of Annex K `_s` functions.
- Kernel code → defer to auditing-kernel.
