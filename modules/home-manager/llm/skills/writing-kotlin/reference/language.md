# Kotlin language

The idioms a reviewer flags that the compiler and ktlint allow.

## Null-safety beyond `?.`

```kotlin
// Bad: !! throws an unhelpful NPE and discards the reason.
val user = repo.find(id)!!

// Good: state the invariant; both smart-cast afterwards.
val user = requireNotNull(repo.find(id)) { "no user for $id" } // bad argument
val cfg  = checkNotNull(loaded) { "config not initialised" }    // bad state
```

`lateinit` is only for genuinely-non-null values set by DI or a lifecycle
callback — not for "I'll set it later" or primitives. Otherwise use a nullable
`var` or `by lazy`.

## Sealed types + exhaustive `when`

```kotlin
sealed interface UiState {
    data object Loading : UiState
    data class Success(val data: Feed) : UiState
    data class Error(val message: String) : UiState
}

// Bad: the else hides the day you add a 4th state.
when (state) {
    is UiState.Success -> show(state.data)
    else -> Unit
}

// Good: no else — adding a variant becomes a compile error.
when (state) {
    UiState.Loading      -> spinner()
    is UiState.Success   -> show(state.data)
    is UiState.Error     -> banner(state.message)
}
```

## Value classes for type-safe IDs

```kotlin
// Bad: every String/Long ID is interchangeable; swapping them compiles.
fun load(userId: String, postId: String)

// Good: zero-allocation wrappers the compiler keeps distinct (unlike typealias).
@JvmInline value class UserId(val value: String)
@JvmInline value class PostId(val value: String)
fun load(userId: UserId, postId: PostId)
```

A `typealias` documents but does not enforce — `value class` does.

## Scope functions — pick by receiver and return

| Function | Receiver | Returns | Use for |
|---|---|---|---|
| `let` | `it` | lambda result | null-safe transform: `x?.let { ... }` |
| `run` | `this` | lambda result | compute a value with `this` in scope |
| `with` | `this` | lambda result | call several methods on one object |
| `apply` | `this` | the object | configure then return it (builders) |
| `also` | `it` | the object | side effect in a chain (logging) |

Don't nest or chain them for cleverness — a plain `val` is often clearer.

## Errors as values

For *expected* failures (a parse that can fail, a lookup that can miss), prefer a
`Result<T>` or a sealed result over throwing. Reserve exceptions for genuinely
exceptional conditions.

## Serialization

Use **kotlinx.serialization** (`@Serializable` + codegen), not Gson or
reflection-based JSON. It needs no reflection, survives R8 shrinking, and is
multiplatform.

```kotlin
@Serializable
data class Config(val name: String, val retries: Int = 3)
```

## Immutability

Expose `val` and read-only types (`List`, `Map`), not `var`/`MutableList`. For
collections that must stay immutable through a Compose boundary, use
`kotlinx.collections.immutable`.
