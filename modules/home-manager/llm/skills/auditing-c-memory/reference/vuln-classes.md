# Vulnerability classes

CWE-anchored, with grep patterns and bad/good pairs. Confirm the three gates
(tainted + reaches + unbounded) before reporting — see SKILL.md.

## Buffer overflow — CWE-787 (write), CWE-125 (read), CWE-120

```c
// Bad A: unbounded string copy.
char dst[64];
strcpy(dst, src);                      // overflows if src > 63

// Good A: bounded, always terminated.
snprintf(dst, sizeof dst, "%s", src);

// Bad B: attacker-controlled memcpy length — the high-severity sink.
memcpy(buf, pkt->data, pkt->len);      // pkt->len from the wire

// Good B
if (pkt->len > sizeof buf) return -1;
memcpy(buf, pkt->data, pkt->len);

// Bad C: off-by-one (the most common real finding).
for (i = 0; i <= N; i++) buf[i] = x;   // writes buf[N]  (CWE-193/787)
buf[strlen(s)] = '\0';                 // needs strlen(s)+1 bytes
```

Grep: `\bstrcpy\s*\(`, `\bstrcat\s*\(`, `\bsprintf\s*\(`, `\bgets\s*\(`,
`memcpy\s*\([^,]+,[^,]+,\s*[a-z_]\w*\s*\)` (non-constant length), `<=` in an index
loop.

## Use-after-free / double-free — CWE-416 / CWE-415

```c
// Bad: dangling use.
free(obj);
log_id(obj->id);                       // UAF

// Bad: use-after-realloc — old pointer aliased.
old = p;
p = realloc(p, n);                     // realloc may move
memcpy(old, ...);                      // UAF

// Bad: double-free on an error path.
if (parse(p) < 0) { free(p); goto err; }
err: free(p);                          // freed twice

// Good: realloc into a temp; free+NULL; single owner.
char *tmp = realloc(p, n);
if (!tmp) { free(p); return -1; }      // realloc failure must not lose the original
p = tmp;
free(obj); obj = NULL;
```

Audit: build a per-variable timeline of `malloc`/`free`/`realloc` and every deref;
flag a deref or second `free` reachable after a `free` with no reassignment.
Error/`goto cleanup` paths are where these hide. (Note: `calloc(n,size)` does the
overflow check, but `realloc(p, n*size)` does not.)

## OOB read — CWE-125 (Heartbleed class)

```c
// Bad: reply with the attacker-claimed length, not the real one.
memcpy(reply, payload, claimed_len);   // over-read if claimed_len > real

// Bad: strlen on a buffer not guaranteed NUL-terminated (strncpy/read output).
n = strlen(buf);
```

## Integer overflow → undersized alloc — CWE-190 / CWE-191 / CWE-197

```c
// Bad: n * size can wrap → tiny buffer → heap overflow downstream.
buf = malloc(n * size);

// Good: overflow-checked, or calloc (which checks the multiply).
if (size && n > SIZE_MAX / size) return NULL;
buf = malloc(n * size);                // or: buf = calloc(n, size);

// Bad: classic underflow and truncation.
memcpy(dst, src, len - 1);             // len==0 → SIZE_MAX
short need = (short)len;               // narrowing → wrong size
```

Grep: `malloc\s*\([^)]*[*+][^)]*\)`, `\blen\s*-\s*1\b`, narrowing casts on sizes.

## Format string — CWE-134

```c
printf(user_input);                    // %n write primitive, %x/%s leaks
// Good
printf("%s", user_input);
```

`-Wformat=2 -Werror=format-security` turns a non-literal format argument into a
build error. Grep: `printf\s*\(\s*\w+\s*\)`, `fprintf\s*\([^,]+,\s*\w+\s*\)`,
`syslog\s*\([^,]+,\s*\w+\s*\)`.

## NULL deref / uninitialized / type confusion — CWE-476 / 457 / 843

```c
p = malloc(n); p->x = 0;               // CWE-476 if malloc returned NULL
char *s; if (cond) s = a; use(s);      // CWE-457 uninitialized on the else path
((struct derived *)b)->field;          // CWE-843 if the tag wasn't checked
```

NULL deref is usually DoS (page 0 is unmappable) — calibrate severity down unless
the attacker controls an offset added to NULL. An uninitialized read is a real
finding when the value reaches a security decision or is sent out.

## Dangerous-function table (gotchas of the "safe" ones)

| Function | Risk (CWE) | Replacement | Gotcha |
|---|---|---|---|
| `gets` | CWE-242/787 | `fgets` | `fgets` keeps the trailing `\n` |
| `strcpy` | CWE-787/120 | `snprintf`/`strlcpy` | — |
| `strncpy` | partial | `snprintf`/`strlcpy` | **no NUL-termination if src ≥ n** → later `strlen` over-reads; pads with NULs |
| `strlcpy`/`strlcat` | bounded | preferred copy | returns *intended* length → silent truncation can be a logic bug; not in every libc |
| `strcat` | CWE-787 | `strlcat`/`snprintf` | `strncat`'s size arg is "chars to append", not buffer size |
| `sprintf` | CWE-787 | `snprintf` | — |
| `snprintf` | size-safe | — | returns the length it *would* have written — `if (r < 0 \|\| (size_t)r >= n)` to detect truncation |
| `scanf("%s")` | CWE-787 | `%63s` or `fgets` | width must be `size - 1` |
| `memcpy`/`memmove` | CWE-787/125 | bound `len` first | `memcpy` UB on overlap → `memmove` |
| `alloca`/VLA | CWE-770 | heap, or cap | no failure signal — overflow just corrupts |
