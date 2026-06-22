# Compose

Recomposition correctness is what a reviewer checks. The compiler skips
composables whose inputs haven't changed — so the bugs are about state ownership,
effect keys, and reading state at the wrong place, none of which a linter sees.

## State hoisting (the big one)

```kotlin
// Bad: the composable owns its state AND reaches into SharedPreferences. Not
// reusable, not testable, mixes UI with persistence.
@Composable
fun SettingsScreen(prefs: SharedPreferences) {
    var dark by remember { mutableStateOf(prefs.getBoolean("dark", false)) }
    Switch(checked = dark, onCheckedChange = {
        dark = it
        prefs.edit().putBoolean("dark", it).apply() // persistence in the UI
    })
}

// Good: state lives in a ViewModel; the composable is stateless — value down,
// events up. Now it previews, tests, and reuses.
@Composable
fun SettingsScreen(state: SettingsUiState, onToggleDark: (Boolean) -> Unit) {
    Switch(checked = state.dark, onCheckedChange = onToggleDark)
}
```

State down, events up (UDF). A stateless composable is the default; introduce
`remember` only for genuinely UI-local, throwaway state (an expanded/collapsed
flag), never for data that should survive the screen.

## Strong skipping changed the rules (Kotlin 2.0.20)

Strong skipping is on by default. A restartable composable is now skippable even
when it has unstable parameters, and lambdas are auto-remembered. So:

```kotlin
// Outdated reflex: wrapping every list in ImmutableList and every lambda in
// remember to "make it skippable". Strong skipping handles both now.

// Reach for kotlinx.collections.immutable's ImmutableList only when you need
// structural-equality skipping (the content, not the reference, decides).
```

Don't cargo-cult `@Stable`/`@Immutable` or `remember { }` around lambdas; add
them when the Layout Inspector / recomposition counts show a real problem.

## Effects and their keys

| Effect | Use for | Key rule |
|---|---|---|
| `LaunchedEffect(key)` | start a coroutine tied to composition | restarts when `key` changes; `Unit` = run once |
| `DisposableEffect(key)` | register + clean up a listener | `onDispose { unregister() }` |
| `SideEffect` | publish Compose state to non-Compose code | runs after every successful recomposition |
| `rememberUpdatedState(x)` | capture the latest `x` in a long-lived effect | use when the effect shouldn't restart but needs fresh `x` |

```kotlin
// Bad: effect restarts every recomposition (no key) or captures a stale callback.
LaunchedEffect(onTimeout) { delay(3000); onTimeout() }

// Good: run once, but call the latest onTimeout.
val latestOnTimeout by rememberUpdatedState(onTimeout)
LaunchedEffect(Unit) { delay(3000); latestOnTimeout() }
```

Never do side effects (mutating external state, launching work) directly in the
composition body — only inside an effect.

## remember vs rememberSaveable

`remember` survives recomposition but **not** configuration changes or process
death. For UI state that must survive rotation (and isn't in a ViewModel), use
`rememberSaveable`.

## derivedStateOf — only when inputs change more often than the output

```kotlin
// Good use: scroll position changes every frame, but you only care about a bool.
val showButton by remember {
    derivedStateOf { listState.firstVisibleItemIndex > 0 }
}
// Misuse: combining two states that change at the same rate — just compute it.
```

## Modifier order is behavior, not cosmetics

`Modifier.padding(16.dp).clickable { }` and `Modifier.clickable { }.padding(16.dp)`
differ: the first makes only the inner area clickable, the second includes the
padding in the touch target. Order chains deliberately; pass a `modifier`
parameter through and apply caller modifiers first.
