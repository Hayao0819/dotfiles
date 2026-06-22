# Architecture

The official Android guidance: a unidirectional-data-flow app split into UI,
(optional) domain, and data layers. This is the most corrective section for code
that reads and writes `SharedPreferences` straight from a Composable.

## The three layers

- **UI layer** — Composables (stateless, hoisted) + a `ViewModel` that holds and
  exposes immutable `UiState` as a `StateFlow`. The UI sends events up; the
  ViewModel produces state down.
- **Domain layer** (optional) — use cases named *verb + noun + `UseCase`*
  (`GetFeedUseCase`), holding business logic that's reused or too complex for a
  ViewModel. No mutable data, no Android types.
- **Data layer** — repositories are the entry point; data sources named
  `*RemoteDataSource` / `*LocalDataSource`. Expose `suspend` for one-shot reads,
  `Flow` for streams. Data classes are immutable. The repository is the single
  source of truth for its data (offline-first → the local DB is the SSOT).

Rule: business logic never lives in an Activity or a Composable, and Android
framework types (`Context`) never leak into domain/data.

## ViewModel + UiState

```kotlin
@HiltViewModel
class FeedViewModel @Inject constructor(
    private val repo: FeedRepository,
    @IoDispatcher private val io: CoroutineDispatcher,
) : ViewModel() {

    private val _uiState = MutableStateFlow<FeedUiState>(FeedUiState.Loading)
    val uiState: StateFlow<FeedUiState> = _uiState.asStateFlow()

    fun refresh() = viewModelScope.launch {
        _uiState.value = runCatching { repo.load() }
            .fold(FeedUiState::Success, { FeedUiState.Error(it.message.orEmpty()) })
    }
}
```

The Composable collects with `collectAsStateWithLifecycle()` and calls
`viewModel::refresh` — it never touches the repository or persistence directly.

## Dependency injection

- **Hilt** is the standard, now KSP-based: `@HiltViewModel`, `@Inject`
  constructors, `@Module @InstallIn(...)` providers, scopes `@Singleton` /
  `@ActivityRetainedScoped` / `@ViewModelScoped`.
- **Koin** is the pure-Kotlin runtime alternative (no KSP; resolution errors
  surface at runtime, not compile time).
- For a tiny app, manual constructor injection is fine — but `object` singletons
  reaching into a `ContentProvider`/`SharedPreferences` (as in some hooked-module
  code) is not DI and isn't testable. Inject dependencies through constructors.

## Why this matters even for a small/hooked app

A ViewModel with injected dependencies is unit-testable without an emulator;
state hoisted out of composition is testable with `compose-ui-test` and
previewable. The architecture isn't ceremony — it's what makes the code
verifiable. If something can't be tested without spinning up the whole app, the
layering is the bug.
