# Tooling

## uv owns the environment

uv replaces pip, pip-tools, pipx, poetry, pyenv, and virtualenv. The workflow:

```sh
uv init                 # new project with pyproject.toml + .python-version
uv python pin 3.13      # pin the interpreter (writes .python-version)
uv add fastapi          # add a runtime dep, update uv.lock + sync
uv add --group lint ruff mypy pylint pyright   # dev tools in a dependency group
uv sync                 # make the venv match the lock
uv sync --locked        # CI: error if the lock is stale (don't silently re-resolve)
uv run pytest           # run inside the project env
uv lock                 # re-resolve and update uv.lock
```

- **Commit `uv.lock`.** It pins exact versions for reproducible installs.
- **Dependency groups (PEP 735), not extras, for dev tools.** `[dependency-groups]`
  is local and never published; `[project.optional-dependencies]` ships with the
  package. Dev tooling belongs in a group:

```toml
[dependency-groups]
dev = ["ruff>=0.15", "mypy>=2", "pylint>=4", "pyright>=1.1.410", "pytest>=9"]
```

- `uvx tool` (= `uv tool run`) replaces pipx for one-off tools; `uv run script.py`
  runs PEP 723 inline-dependency scripts; `[tool.uv.workspace]` shares one lock
  across a monorepo (as `ciste` does).
- Migration targets in the existing code: `requirements.txt` services and the one
  `poetry` project → uv.

## Strict type checking — ship the config

The existing repos type-check loosely; the standing preference is strict. Ship
these (full files in [../assets/](../assets/)):

- **mypy `--strict`** turns on `disallow_untyped_defs`, `disallow_any_generics`,
  `check_untyped_defs`, `warn_return_any`, `warn_unused_ignores`,
  `strict_equality`, and more. Add `warn_unreachable` (not in `--strict`).
- **Pyright `strict`** uniquely flags the `reportUnknown*` family (member,
  parameter, variable, argument types) and unnecessary casts/comparisons — bugs
  mypy won't surface. It's the Pylance engine, so this is what the editor shows.

Run both: they catch different things. mypy has the plugin API (pydantic/SQLAlchemy);
pyright is stricter on untyped third-party surfaces.

## pylint and ruff are complementary

- **ruff** (`ruff check` + `ruff format`) replaces flake8, isort, black,
  pyupgrade, and a `PL` subset of pylint — fast, run it first. `ruff format` is
  >99.9% black-identical.
- **pylint** stays for what ruff structurally can't do (it has no type inference
  or cross-file analysis): `no-member`, `cyclic-import`, the `too-many-*` design
  checks, and `duplicate-code`. Keep it; don't let "ruff replaces pylint" drop
  those.

Order in CI: `ruff format` → `ruff check --fix` → `pylint` → `mypy --strict` →
`pyright` → `pytest`.

## pytest

- Fixtures (`yield` for setup/teardown), scopes (`function` → `session`),
  `@pytest.mark.parametrize` for cartesian cases, `conftest.py` for shared
  fixtures, `tmp_path` for filesystem tests.
- Prefer `monkeypatch` over `unittest.mock` for env vars, globals, and attributes
  (it auto-reverts). Avoid over-mocking — a real object or a small fake beats a
  mock whose script can drift from reality.
- `pytest.raises(...)` for error paths; register custom markers.
- Async: `pytest-asyncio` with `asyncio_mode = "auto"` (the default is `strict`).
