# The stack

Measured across the engineer's own Python projects in `~/Git`. Default to the
established choice; flag splits rather than picking unilaterally.

## De-facto choices

| Category | Choice | Notes |
|---|---|---|
| Env / packaging | **uv** (13 `uv.lock` files, `.python-version` pins) | the baseline; migrate `requirements.txt`/poetry holdouts |
| Web framework | **FastAPI** | dominates (the "Parking-App is Flask" memory is off — that one is stdlib `http.server`) |
| Async | **asyncio** (native) | heavy `async def` usage; aiohttp for HTTP, SQLAlchemy async + asyncpg |
| Validation | **pydantic** (BaseModel) | first choice; dataclasses second; attrs/NamedTuple barely used |
| ORM | **SQLAlchemy 2.x** | async style |
| CLI | **argparse** (stdlib) | no click/typer in the codebase |
| Testing | **pytest** | unittest still lingers in older code; pytest-asyncio for async |
| Data / ML | numpy, pandas, opencv, scikit-learn, torch, ultralytics, xgboost | real vision/ML work |
| Build backend | **hatchling** | where projects are packaged |

## Python version

3.14 is current stable, but these projects target **3.13** (newest), with some on
3.12 (ciste) or floored at 3.10 (attestation tooling, MCP servers) for compat. Use
3.13 as the safe modern baseline for examples; gate 3.14-only features (t-strings,
default deferred annotations) explicitly.

## HTTP client — a mild split

`urllib` (stdlib, in the attestation tooling), `aiohttp` (async code), `requests`
(sync scripts), and `httpx` all appear. Inside `async def`, use an async client
(`aiohttp`/`httpx`), never `requests`. For a simple sync script, stdlib `urllib`
or `requests` is fine — match the surrounding project.

## Where the existing code diverges from the stated standard

The standing preference is uv + explicit hints + strict mypy/pylint/pyright, but
the repos haven't fully caught up — these are the cleanup targets, not the
baseline to imitate:

- `requirements.txt` services (SOMS, Office, gity_library) and one `poetry`
  project → uv.
- Hundreds of `Optional[...]`, `List/Dict/...`, `os.path`, and `%`/`.format`
  occurrences in first-party code → the modern forms in
  [type-hints.md](type-hints.md) and [idioms.md](idioms.md).
- No project currently runs mypy `strict = true` → ship the strict config from
  [../assets/](../assets/) on new work.
