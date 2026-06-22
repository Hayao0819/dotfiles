# Async

The highest-value non-obvious material in Rust, because async code compiles
cleanly and then loses data or deadlocks at runtime. Tokio is the de-facto
runtime; pin `tokio = "1"`.

## Cancellation safety in `select!`

Cancellation in async Rust means **a future is dropped**. In a `select!` loop,
every branch that didn't complete is dropped on each iteration — so the future in
a losing branch must tolerate being dropped mid-flight.

```rust
// Bad: read_exact is NOT cancel-safe. If another branch fires mid-read, the
// partially-filled buffer is discarded — silent data loss.
loop {
    tokio::select! {
        _ = socket.read_exact(&mut buf) => process(&buf),
        _ = shutdown.recv() => break,
    }
}

// Good: pin a long-lived future outside the loop and only re-arm on completion,
// or use a cancel-safe op (framed read, recv).
```

**Cancel-safe** (fine to drop): `mpsc`/`broadcast`/`watch::recv`, `oneshot`,
`TcpListener::accept`, `read`/`read_buf`, `write`/`write_buf`.
**Not cancel-safe — lose data:** `read_exact`, `read_to_end`, `read_to_string`,
`write_all` (partial buffer dropped).
**Not cancel-safe — lose queue position:** `tokio::Mutex::lock`, `RwLock`,
`Semaphore::acquire`, `Notify::notified`.

## Don't hold a non-Send guard across `.await`

```rust
// Bad: the std MutexGuard isn't Send, so this future isn't Send, so spawn rejects it.
let data = state.lock().unwrap();
do_async(&data).await;  // guard held across await — compile error under spawn

// Good: scope the guard out before the await.
let value = {
    let data = state.lock().unwrap();
    data.value
}; // guard dropped here
do_async(value).await;
```

Same trap with `Rc` and a `RefCell` borrow held across an await point.

## Which mutex

- Default to `std::sync::Mutex` inside async code — it's fine as long as
  contention is low and **you don't hold the lock across `.await`** (the `!Send`
  guard makes the compiler enforce that for you).
- Use `tokio::sync::Mutex` only when you genuinely must hold a lock across an
  await — and remember its `lock()` is not cancel-safe.
- For ownership transfer between tasks, prefer message passing (`mpsc`/`oneshot`)
  over shared state.

## When NOT to go async

- CPU-bound work: use threads or `rayon`. Blocking the executor starves every
  co-scheduled task.
- Simple CLIs / batch programs: plain blocking code is simpler and just as fast.
  Async earns its complexity at I/O concurrency scale, not by default.
- Short blocking I/O inside async: `tokio::task::spawn_blocking`. Heavy compute:
  `rayon`, not the async runtime.

## Traits

Native `async fn` in traits (AFIT, 1.75) works for static dispatch — drop
`#[async_trait]` there. But a trait with `async fn` is **not dyn-compatible**, so
for `dyn Trait` you still need `#[async_trait]` (which boxes the future) or a
manual `-> Pin<Box<dyn Future>>`.
