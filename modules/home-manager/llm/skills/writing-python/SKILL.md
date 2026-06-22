---
name: writing-python
description: >-
  Idiomatic, version-current, strictly-typed Python review and authoring for an
  experienced engineer who insists on uv for environment/version management,
  explicit type hints everywhere, and thorough checking with mypy + pylint +
  Pylance (Pyright). Covers the modern typing surface (X | None, list[str],
  PEP 695 generics, Self, Protocol, TypedDict, TypeIs, assert_never, @override,
  avoiding Any), the uv workflow and dependency groups, pydantic-at-boundaries,
  pathlib/f-strings/match idioms, and the strict tool configs to ship. Use when
  writing or reviewing Python — .py files, pyproject.toml, type errors, uv
  commands — or before committing Python. Flags Optional[X], List[], os.path,
  %-format, and poetry/requirements.txt.
---

# Writing Python

A reviewer for someone whose standing rules are: **uv** for everything
environment/version-related, **explicit type hints on every signature**, and a
clean pass under **mypy + pylint + Pyright/Pylance**. The skill encodes that
strictness and the modern typing surface — and ships the strict tool configs the
existing repos are missing.

> Compatibility (re-verify on ship): Python 3.14 is current stable (GA 2025-10);
> 3.13 is the safe modern baseline these projects target (some floor at 3.12/3.10
> for compat). uv 0.11, mypy 2.x, pyright 1.1.41x, pylint 4, ruff 0.15 (as a
> complement, not a pylint replacement), pytest 9.

## When to use

- Writing or reviewing any `.py`, or editing `pyproject.toml`.
- Any typing question, a mypy/pyright error, or an environment/dependency task.
- Before committing Python: run the tooling pass at the bottom.

## How to read this skill

| Open this | When |
|---|---|
| [reference/type-hints.md](reference/type-hints.md) | the modern typing surface — the core of this skill |
| [reference/tooling.md](reference/tooling.md) | uv workflow, strict mypy/pyright, pylint vs ruff, pytest |
| [reference/idioms.md](reference/idioms.md) | pydantic vs dataclass, pathlib, f-strings, match, EAFP |
| [reference/stack.md](reference/stack.md) | the de-facto libraries (FastAPI, asyncio, pydantic, argparse) |

## What changed — stop writing the old form

These appear hundreds of times across the existing code; flag them on sight.

| Old form | Modern form | Since |
|---|---|---|
| `Optional[X]` | `X \| None` | 3.10 |
| `Union[A, B]` | `A \| B` | 3.10 |
| `List[str]`, `Dict[k, v]`, `Tuple`, `Set` | `list[str]`, `dict[k, v]`, `tuple`, `set` | 3.9 |
| `TypeVar("T")` + `Generic[T]` | `class C[T]:` / `def f[T](...)` | 3.12 |
| `TypeAlias` | `type X = ...` | 3.12 |
| `TypeGuard` | `TypeIs` (narrows both branches) | 3.13 |
| always `from __future__ import annotations` | unnecessary on 3.14 (deferred eval is default) | 3.14 |
| `os.path.join`/`exists`/`dirname` | `pathlib.Path` | — |
| `"%s" % x`, `"{}".format(x)` | f-strings | — |
| poetry / pyenv / pipx / pip-tools / `requirements.txt` | **uv** (`uv add`, `uv.lock`, `uv python pin`) | — |
| `[project.optional-dependencies] dev` for dev tools | `[dependency-groups]` (PEP 735) | — |

## Highest-leverage review checks

- **Every function signature is fully annotated** — parameters and return. No
  implicit `Any`, no untyped `def`. Prefer `object` + narrowing over `Any`; reserve
  `Any` for genuine dynamic boundaries and `cast()` for the rare unprovable case.
  → [reference/type-hints.md](reference/type-hints.md)
- **Parse external data into pydantic models at the boundary** (request bodies,
  config, API responses). Types are erased at runtime — pydantic is what makes the
  annotation true. Use dataclasses for internal, already-trusted data.
  → [reference/idioms.md](reference/idioms.md)
- **Exhaustiveness with `assert_never`.** A `match`/`if` over a closed set ends in
  a `case _ as unreachable: assert_never(unreachable)` so adding a variant is a
  type error. → [reference/type-hints.md](reference/type-hints.md)
- **`Protocol` for structural typing** when you don't own the type or want duck
  typing; an ABC only for an owned hierarchy needing runtime enforcement.
- **uv owns the environment.** `uv add`/`uv sync`/`uv run`/`uv python pin`, a
  committed `uv.lock`, dev tools in `[dependency-groups]`. No bare `pip install`,
  no `requirements.txt` in new work. → [reference/tooling.md](reference/tooling.md)
- **Strict means strict.** mypy `--strict` and Pyright `strict` both clean; pylint
  for the inference/design checks ruff can't do. The configs to ship are in
  [assets/](assets/). → [reference/tooling.md](reference/tooling.md)

## Tooling pass (before commit)

```sh
uv sync --locked          # environment matches the lockfile (CI gate)
uv run ruff format .       # format (replaces black) + import sort
uv run ruff check --fix .  # fast lint + modernization (PL subset, pyupgrade)
uv run pylint src          # inference, design, duplicate-code — what ruff can't
uv run mypy --strict src   # type check
uv run pyright             # Pylance engine; catches reportUnknown* mypy misses
uv run pytest
```

ruff is a **complement** to pylint, not a replacement: ruff is fast and covers
formatting/imports/modernization and a subset of pylint's rules, but `no-member`,
`cyclic-import`, the `too-many-*` design checks, and `duplicate-code` need
pylint's type inference and multi-file analysis. Keep both. Starter configs:
[assets/mypy.reference.toml](assets/mypy.reference.toml),
[assets/pyrightconfig.reference.json](assets/pyrightconfig.reference.json),
[assets/pylintrc.reference.toml](assets/pylintrc.reference.toml).

## What this skill is not

- Not a Python tutorial, and not a restatement of ruff/pylint/mypy rules. Route
  mechanical checks to the tools; the skill is the judgment around them.
- It respects the stated stack: ruff is added *around* pylint+mypy+pyright, not in
  place of them.
- Prose it helps you write (docstrings, comments) goes through **natural-writing** —
  don't restate the signature in the docstring.
