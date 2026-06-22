# Framework-specific

## Go / Gin / GORM

- **SQLi surfaces:** `db.Raw`/`db.Exec` + concatenation; clause methods taking raw
  fragments (`Order`/`Group`/`Having`/`Select`/`Distinct`, `Where("…"+x)`). **Safe:**
  `?`/`@name` placeholders and struct-based `Where`. Identifiers/ORDER BY →
  allowlist (not parameterizable). See [injection.md](injection.md).
- **Input binding/validation:** `c.ShouldBindJSON` with `binding:"required,email"`
  tags; bind to **DTOs, not persistence models**, to prevent mass assignment (see
  [access-control.md](access-control.md)).
- **Middleware auth ordering:** auth middleware must be registered **before** the
  protected route group, and must `c.Abort()` (not just `c.Next()`) on failure.
  Flag routes added outside the `r.Group(...).Use(authMiddleware)` chain.

```go
// Bad: auth middleware doesn't abort — request proceeds unauthenticated.
func Auth(c *gin.Context) {
    if !valid(c) { c.JSON(401, ...) }   // missing c.Abort() — handler still runs
    c.Next()
}
// Good
func Auth(c *gin.Context) {
    if !valid(c) { c.AbortWithStatus(401); return }
    c.Set("userID", uid)
    c.Next()
}
```

- **Context propagation:** a scoped `userID`/tenant set in middleware via `c.Set`
  must actually be *read* where authz matters — verify it.
- **Error leakage:** never return `err.Error()` to the client.

## Next.js / App Router / Server Actions

- **Server Actions are public, unauthenticated POST endpoints.** Every `"use
  server"` action must, in order: (1) check **identity** (valid session), (2) check
  **ownership/role** on the target resource, (3) **validate input** with zod (types
  are erased at runtime). Reachable via a crafted POST regardless of the UI. Flag a
  `"use server"` export that doesn't read the session. See
  [access-control.md](access-control.md) for the canonical good example.
- **Route Handlers** (`app/api/.../route.ts`): enforce auth **inside** the handler,
  not from middleware alone.
- **Middleware is not an auth boundary (CVE-2025-29927):** middleware-based authz
  was bypassable via the `x-middleware-subrequest` header. Enforce auth in the
  action / handler / data-access layer, never solely in middleware.
- **`NEXT_PUBLIC_` leakage (CWE-200):** any `NEXT_PUBLIC_*` value is inlined into
  the client bundle — flag secrets with that prefix, and any `process.env.SECRET`
  referenced from a module imported by a `"use client"` component.
- **Server→Client boundary exposure:** a Server Component passing a full object
  (with secret fields) as props to a Client Component. Safe mitigations to
  recognize: `import "server-only"`, a data-access layer that alone touches
  `process.env`, and React `experimental_taintObjectReference`/`taintUniqueValue`.

```ts
// Bad: passes the whole user row (incl. passwordHash) to the client.
return <Profile user={user} />;
// Good: pass a DTO with only public fields.
return <Profile user={{ id: user.id, name: user.name }} />;
```
