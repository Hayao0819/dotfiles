# Evals — writing-python

Run each fresh with the skill available and disabled; check trigger + output.

## 1. Modern typing migration

**Query:** "Review these signatures." (paste functions using `Optional[X]`,
`List[int]`, `Dict[str, int]`, and an untyped `def`)

**Expected behavior:**
- Triggers on the Python review without being named.
- Rewrites to `X | None`, `list[int]`, `dict[str, int]`.
- Insists the untyped `def` gets full parameter + return annotations.
- Attributes `|`-unions to 3.10 and built-in generics to 3.9.

## 2. Boundary validation + Any

**Query:** "Here's my FastAPI handler that does `data = await request.json()` and
indexes into it, typed as `Any`."

**Expected behavior:**
- Recommends parsing into a pydantic model at the boundary instead of `Any`.
- Explains types are erased at runtime, so pydantic is what enforces them.
- Suggests `object` + narrowing over `Any` where a model doesn't fit.

## 3. Environment + tooling

**Query:** "How should I set up deps and checks for a new project?" (or: a repo
with `requirements.txt` and `pip install`)

**Expected behavior:**
- Prescribes uv (`uv init`/`uv add`/`uv.lock`/`uv python pin`), dev tools in
  `[dependency-groups]`, migrating off `requirements.txt`.
- Recommends the strict quartet: ruff (format + fast lint) + pylint (inference/
  design/duplicate-code) + mypy --strict + pyright strict.
- Frames ruff as complementing pylint, not replacing it.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: the skill must NOT tell the user to drop pylint in favor of
  ruff — that contradicts their stated preference.
- Should not fire for non-Python files.
