# Type hints

The core of this skill: explicit, modern, strict typing. Every signature is
annotated; the type system is the design tool, not an afterthought.

## Modern syntax (use these, flag the old ones)

```python
# Bad (old): still the majority of the existing code.
from typing import Optional, List, Dict, Union, TypeVar, Generic

T = TypeVar("T")
def first(xs: List[int]) -> Optional[int]: ...
class Box(Generic[T]): ...
def parse(x: Union[str, bytes]) -> Dict[str, int]: ...

# Good (3.12+): built-in generics, | unions, PEP 695 type params.
def first(xs: list[int]) -> int | None: ...
class Box[T]: ...
def parse(x: str | bytes) -> dict[str, int]: ...
type Json = dict[str, Json] | list[Json] | str | int | float | bool | None
```

PEP 695 `type` aliases evaluate lazily, so the self-reference needs **no** string
quotes (quoting it would contradict the "stop string-wrapping forward refs"
guidance above).

`from __future__ import annotations` is still useful for forward references on
≤3.13, but unnecessary on 3.14 (deferred annotation evaluation is the default).

## Narrowing and exhaustiveness

```python
from typing import assert_never

type Shape = Circle | Square | Triangle

def area(s: Shape) -> float:
    match s:
        case Circle(r):   return 3.14159 * r * r
        case Square(a):   return a * a
        case Triangle(b, h): return 0.5 * b * h
        case _ as unreachable:
            assert_never(unreachable)  # adding a Shape variant becomes a type error
```

## TypeIs over TypeGuard (3.13)

```python
from typing import TypeIs

# TypeIs narrows BOTH branches and intersects with the prior type — what you
# almost always want.
def is_str(x: object) -> TypeIs[str]:
    return isinstance(x, str)

# Use the older TypeGuard only when narrowing to an incompatible type
# (e.g. list[object] -> list[int]), where two-way narrowing would be wrong.
```

## Protocol over ABC for structural typing

```python
from typing import Protocol

# Good: structural — anything with a matching read() satisfies it, no inheritance.
class Readable(Protocol):
    def read(self, n: int = -1) -> bytes: ...

def consume(src: Readable) -> bytes: ...
```

Use a `Protocol` when you don't own the implementing types or want duck typing;
use an ABC when you own the hierarchy and want runtime `isinstance` enforcement.

## TypedDict, Self, override, deprecated

```python
from typing import TypedDict, Required, NotRequired, Self, override

class Config(TypedDict):
    host: Required[str]
    port: NotRequired[int]      # 3.11

class Builder:
    def with_host(self, h: str) -> Self:  # 3.11 — returns the subclass type
        self._host = h
        return self

class Base:
    def run(self) -> None: ...

class Job(Base):
    @override                    # 3.12 — error if it doesn't actually override
    def run(self) -> None: ...
```

`@deprecated("use X")` (PEP 702, 3.13) marks an API; type checkers flag callers.
It lives in **`warnings`** (`from warnings import deprecated`), not `typing` —
`typing_extensions` has the backport for < 3.13.

## Avoid Any

`Any` switches off checking and spreads. Prefer:

- `object` + an `isinstance`/`match` narrow when the value really is unknown.
- A `Protocol` or union when you know the shape.
- A pydantic model when it's external data ([idioms.md](idioms.md)).

`cast(T, x)` is a last resort that asserts without checking — comment why it's
sound. `reveal_type(x)` (no import needed under a checker) is the debugging tool
when an inferred type surprises you.
