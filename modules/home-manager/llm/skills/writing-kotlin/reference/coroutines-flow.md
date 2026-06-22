# Coroutines & Flow

Structured concurrency is the whole point: a coroutine belongs to a scope, gets
cancelled with it, and never outlives what spawned it. Most coroutine bugs are a
scope, dispatcher, or cancellation mistake.

## Mistake | Problem | Fix

| Mistake | Problem | Fix |
|---|---|---|
| `GlobalScope.launch { }` | uncancellable, leaks past the screen, untestable | `viewModelScope` / `lifecycleScope` / an injected scope |
| `withContext(Dispatchers.IO)` hardcoded | can't inject a `TestDispatcher` — slow, flaky tests | inject `CoroutineDispatcher`; default it to IO |
| a suspend fn that blocks the caller's thread | leaks threading concerns to callers | make it **main-safe**: `withContext` *inside* the function |
| `public val state: MutableStateFlow` | anyone can mutate your state | `private val _state`; expose `_state.asStateFlow()` |
| `catch (e: Exception)` swallowing cancellation | `CancellationException` caught → coroutine "cancelled" but keeps running | rethrow it: `if (e is CancellationException) throw e`; or `ensureActive()` in loops |
| `collectAsState()` in a Composable | keeps collecting while the app is backgrounded (battery, leaks) | `collectAsStateWithLifecycle()` |
| `stateIn(scope, Eagerly, ...)` for screen state | collects offscreen, wasting work | `stateIn(scope, SharingStarted.WhileSubscribed(5_000), initial)` |
| `flowOn` placed below the collector | only affects upstream — does nothing where you put it | put `flowOn` directly above the work it should move |
| `callbackFlow { }` without `awaitClose` | the listener leaks / the flow ends early | `awaitClose { unregister() }`, emit with `trySend` |

## Dispatcher injection

```kotlin
// Bad: untestable — the test runs the real IO dispatcher.
class Repo {
    suspend fun load() = withContext(Dispatchers.IO) { api.fetch() }
}

// Good: inject it; tests pass a TestDispatcher and control virtual time.
class Repo(private val io: CoroutineDispatcher = Dispatchers.IO) {
    suspend fun load() = withContext(io) { api.fetch() } // still main-safe
}
```

## StateFlow vs SharedFlow vs LiveData

- **`StateFlow`** — UI *state* that always has a current value. The default for a
  ViewModel's `UiState`.
- **`SharedFlow`** — one-shot *events* (navigation, snackbars) that shouldn't
  replay on re-collection. Use `MutableSharedFlow(extraBufferCapacity = 1)`.
- **`LiveData`** — legacy. New code uses `StateFlow` + `collectAsStateWithLifecycle`.

```kotlin
class FeedViewModel(repo: Repo, scope: CoroutineScope) : ViewModel() {
    val uiState: StateFlow<UiState> =
        repo.feed()                                  // a cold Flow
            .map { UiState.Success(it) }
            .stateIn(
                viewModelScope,
                SharingStarted.WhileSubscribed(5_000), // survives rotation, stops offscreen
                UiState.Loading,
            )
}
```

```kotlin
// In the Composable:
val state by viewModel.uiState.collectAsStateWithLifecycle()
```

## Cancellation is cooperative

A coroutine only stops at a suspension point or where it checks. In a long CPU
loop, call `ensureActive()` (or `yield()`) so cancellation can take effect — and
never catch `CancellationException` without rethrowing.
