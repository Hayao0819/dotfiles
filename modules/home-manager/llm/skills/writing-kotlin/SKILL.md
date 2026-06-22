---
name: writing-kotlin
description: >-
  Idiomatic, version-current Kotlin/Android review and authoring for an
  experienced engineer, Compose-first on Kotlin 2.x (K2). Covers coroutines/Flow
  pitfalls (GlobalScope, hardcoded dispatchers, exposed MutableStateFlow,
  collectAsStateWithLifecycle, stateIn), Compose idioms the linter misses (state
  hoisting, strong skipping, effect keys, derivedStateOf, modifier order),
  Kotlin language idioms (!! and lateinit, sealed + exhaustive when, value
  classes, kotlinx.serialization over Gson), and the official UI/domain/data
  architecture with Hilt. Use when writing or reviewing Kotlin or Android —
  .kt files, Composables, ViewModels, Gradle/version catalogs, coroutines — or
  Jetpack Compose UI. Pairs with the android-control skill for on-device work.
---

# Writing Kotlin

A reviewer for Android/Compose code on Kotlin 2.x. It assumes you know Kotlin
syntax, coroutines, and Compose basics, and spends its budget on the pitfalls a
reviewer catches: coroutine scope/dispatcher discipline, recomposition
correctness, exhaustive modeling, and architecture layering.

Know the engineer's real shape before applying the architecture guidance: their
code is **(a)** a large legacy **Views + Java** app (Iconify: no Compose, no
Hilt) and **(b)** small **LSPosed/Xposed + ReVanced** surfaces (mtga: one Compose
screen, no DI graph, running inside a foreign app process). The full UI/domain/
data + Hilt + StateFlow architecture below is the target for **new** UI, not a
description of what they ship today — so present it as direction, and don't flag
context-appropriate exceptions (see the do-not-flag note). The biggest real
opportunities are extracting testable pure logic and migrating the old
Views/BOM/Kotlin baselines, not retrofitting MVVM onto hook code.

> Compatibility (re-verify on ship): Kotlin 2.4 (K2 default since 2.0); Compose
> BOM 2026.06.00 (material3 1.4, ui 1.11); AGP 9.2; KSP2 (KAPT is in maintenance
> — migrate). Strong skipping is default since Kotlin 2.0.20. Pin via a
> `libs.versions.toml` version catalog. Note: KSP can lag the newest Kotlin —
> verify the KSP release supports your Kotlin before bumping.

## When to use

- Writing or reviewing any `.kt`, a Composable, a ViewModel, or Gradle/version-
  catalog files.
- Any coroutines/Flow, recomposition, or app-architecture question.

For driving an emulator/device over adb, that's **android-control**.

## How to read this skill

| Open this | When |
|---|---|
| [reference/coroutines-flow.md](reference/coroutines-flow.md) | scopes, dispatchers, StateFlow/SharedFlow, `stateIn`, lifecycle collection |
| [reference/compose.md](reference/compose.md) | state hoisting, strong skipping, effects/keys, `derivedStateOf`, modifiers |
| [reference/language.md](reference/language.md) | null-safety, sealed + `when`, value classes, scope functions, serialization |
| [reference/architecture.md](reference/architecture.md) | UI/domain/data, UDF, ViewModel + UiState, Hilt/KSP |

## What changed — stop writing the old form

| Old form | Modern form | Note |
|---|---|---|
| KAPT annotation processing | **KSP** | KAPT is in maintenance mode; KSP is faster |
| `LiveData` | `StateFlow` + `collectAsStateWithLifecycle()` | LiveData is legacy |
| `collectAsState()` in Android UI | `collectAsStateWithLifecycle()` | plain version keeps collecting in the background |
| `kotlinCompilerExtensionVersion` / standalone compose-compiler | `org.jetbrains.kotlin.plugin.compose` | the old plugin is dead on Kotlin 2.x |
| `ImmutableList`-wrapping / `remember`-wrapping every lambda | usually unnecessary | strong skipping (2.0.20) handles unstable params and lambda memoization |
| `GlobalScope.launch` | `viewModelScope` / `lifecycleScope` / injected scope | GlobalScope is uncancellable and untestable |
| `AsyncTask`, RxJava-for-everything | coroutines + Flow | |
| Gson / reflection-based JSON | `kotlinx.serialization` | codegen, no reflection, survives R8 |
| `io.gitlab.arturbosch.detekt` | `dev.detekt` is the 2.x id — but 2.0 is still **alpha** (mid-2026); stay on `io.gitlab.arturbosch.detekt` (the stable id) until 2.0 ships GA | not yet a settled migration |

## Highest-leverage review checks

- **No `GlobalScope`, no hardcoded `Dispatchers.IO`.** Launch in
  `viewModelScope`/`lifecycleScope`; inject the dispatcher so tests can swap a
  `TestDispatcher`. Make suspend functions main-safe (the `withContext` lives
  inside them). → [coroutines-flow.md](reference/coroutines-flow.md)
- **Never expose a `MutableStateFlow`.** Keep `private val _x`; expose
  `_x.asStateFlow()`. Collect UI state with `collectAsStateWithLifecycle()`, and
  cold→hot with `stateIn(scope, WhileSubscribed(5_000), initial)`.
- **Hoist state; prefer not to read/write `SharedPreferences` from a Composable.**
  Lift state to a ViewModel exposing immutable `UiState`; pass `value` down and
  events up — the biggest correctness/testability win for a normal app. **But do
  not flag** threading `SharedPreferences` through composables in an LSPosed/Xposed
  hooked process or a tiny settings surface with no DI graph (mtga's real case): a
  thin state holder is enough there, a full Hilt ViewModel is inappropriate.
  → [architecture.md](reference/architecture.md)
- **Effect keys are load-bearing.** `LaunchedEffect(Unit)` runs once;
  `LaunchedEffect(id)` restarts when `id` changes. Wrong key → stale lambda or a
  restart every recomposition. Use `rememberUpdatedState` for callbacks in a
  long-lived effect. → [compose.md](reference/compose.md)
- **Drop the `else` on a `when` over a sealed type** so a new subtype is a
  compile error. Prefer `requireNotNull`/`checkNotNull` over `!!`, and a
  `@JvmInline value class` over a bare `String`/`Long` ID.
  → [language.md](reference/language.md)
- **Find the testable seam.** A ViewModel with injected dispatchers is
  unit-testable (Turbine for Flows); a hoisted Composable with `compose-ui-test`.
  For hook/patch code that runs in a foreign process, the seam is the **pure
  logic** (symbol resolvers, config/parse in `mod/common`) — extract and test
  that; don't chase emulator-coupled coverage or nag "add tests" without it.

## Tooling pass (before commit)

```sh
./gradlew ktlintCheck        # or: detekt (io.gitlab.arturbosch.detekt; 2.x/dev.detekt is alpha)
./gradlew :app:lint          # Android Lint
./gradlew testDebugUnitTest  # JUnit + MockK + Turbine
./gradlew assembleDebug      # R8 is on for release; check it builds
```

Add the Compose lint rules (`io.nlopez.compose.rules`) to catch recomposition
anti-patterns the base linters miss.

## What this skill is not

- Not a Kotlin or Compose tutorial, and not a restatement of ktlint/detekt/
  Android Lint. Route style to the tool.
- Not about reverse-engineering/patching APKs (the engineer does that in mtga) —
  this is about *writing* Kotlin.
- Prose it helps you write (KDoc, comments) goes through **natural-writing**.
