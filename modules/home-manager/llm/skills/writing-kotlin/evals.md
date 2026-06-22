# Evals — writing-kotlin

Run each fresh with the skill available and disabled; check trigger + output.

## 1. Coroutine scope/dispatcher

**Query:** "Review this repository." (paste a class using `GlobalScope.launch`
and a hardcoded `withContext(Dispatchers.IO)`, exposing a public
`MutableStateFlow`)

**Expected behavior:**
- Flags `GlobalScope` (uncancellable, untestable) → an injected/viewModel scope.
- Flags the hardcoded dispatcher → inject `CoroutineDispatcher` for testability.
- Flags the public `MutableStateFlow` → expose `asStateFlow()`.

## 2. Compose state ownership

**Query:** "Here's my settings screen." (paste a Composable that reads/writes
`SharedPreferences` inline and owns `mutableStateOf`)

**Expected behavior:**
- Recommends hoisting state to a ViewModel and making the Composable stateless
  (value down, events up).
- Moves persistence out of the UI.
- Mentions `collectAsStateWithLifecycle` for collecting the state.
- Does NOT cargo-cult `ImmutableList`/`remember`-wrapping (strong skipping).

## 3. Modeling + stale idioms

**Query:** "Anything outdated here?" (paste a `when` over a sealed class with an
`else`, a `!!`, `LiveData`, and a KAPT setup)

**Expected behavior:**
- Drops the `else` for exhaustiveness; replaces `!!` with `requireNotNull`.
- Flags `LiveData` → `StateFlow` + lifecycle collection, and KAPT → KSP.
- Suggests `@JvmInline value class` if there are stringly-typed IDs.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: should defer to **android-control** for adb/emulator
  driving, not answer it here.
- Should not fire for non-Kotlin files or pure Gradle-version bumps.
