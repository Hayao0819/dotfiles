# Idioms

Reviewer-level calls beyond what the linters enforce.

## pydantic vs dataclass vs the rest

| Use | When |
|---|---|
| **pydantic** `BaseModel` | data crossing a boundary — request/response bodies, config, external API payloads. Validation + parsing at runtime makes the type annotation actually true. The de-facto choice here. |
| **dataclass** | internal, already-trusted structured data with little/no validation. Stdlib, no dependency, supports `slots=True`, `frozen=True`. |
| **NamedTuple** | a small immutable record you also want to treat as a tuple. |
| **TypedDict** | typing a plain dict you can't or won't convert to a model (e.g. a JSON shape passed through). |

```python
# Boundary: parse, don't trust.
from pydantic import BaseModel

class CreateUser(BaseModel):
    email: str
    age: int

user = CreateUser.model_validate(await request.json())  # raises on bad input

# Internal: a dataclass is lighter and needs no validation.
from dataclasses import dataclass

@dataclass(slots=True, frozen=True)
class Point:
    x: float
    y: float
```

## pathlib over os.path

```python
# Bad: os.path string-juggling (hundreds of occurrences in the existing code).
import os
path = os.path.join(os.path.dirname(__file__), "data", "x.json")
if os.path.exists(path): ...

# Good: pathlib — operators, methods, typed Path objects.
from pathlib import Path
path = Path(__file__).parent / "data" / "x.json"
if path.exists(): ...
text = path.read_text()
```

## f-strings, comprehensions, EAFP

- **f-strings** over `%` and `.format()` (hundreds of legacy occurrences to flag).
  `f"{value!r}"` for repr, `f"{x:.2f}"` for format specs, `f"{x=}"` for debug.
- **Comprehensions** over trivial accumulation loops; a generator (`(... for ...)`)
  when streaming or when you don't need the whole list materialized.
- **`enumerate`/`zip`** over manual index bookkeeping.
- **EAFP over LBYL** — `try: ... except KeyError:` rather than `if k in d` then
  access, when the happy path dominates. It's idiomatic and avoids a TOCTOU gap.

## match — only for genuine structural dispatch

`match` earns its keep destructuring shapes (a `Shape` union, a parsed message), or
with class/sequence/mapping patterns. Don't rewrite a plain `if/elif` chain on a
single value into `match` for style — and pair it with `assert_never` for
exhaustiveness ([type-hints.md](type-hints.md)).

## Common traps

- **No mutable default arguments** (`def f(x, acc=[])`) — the list is shared across
  calls. Use `acc: list[int] | None = None` then `acc = [] if acc is None else acc`
  — **not** `acc = acc or []`, which silently discards a caller-passed empty list
  (`[]` is falsy).
- **`@cached_property`** for an expensive attribute computed once per instance.
- **Context managers** (`with`) for anything with cleanup — files, locks, sessions,
  `contextlib.contextmanager` for your own.
- **Async:** this code is asyncio-heavy. Don't block the event loop with sync I/O;
  use `asyncio.to_thread` for unavoidable blocking calls, and an async client
  (`aiohttp`/`httpx`) not `requests` inside `async def`.
