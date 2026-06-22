# SSRF, CSRF, traversal, deserialization, CORS, secrets

## SSRF — CWE-918 (A01:2025, absorbed)

Flag when an attacker-controlled URL/host reaches an HTTP client. Safe when the
base URL is config/constant and only a validated path/ID is appended.

```go
resp, _ := http.Get(c.Query("url"))     // Bad: full URL from user
// Good: fixed host; allowlist; block internal ranges + redirects.
```

Mitigations to confirm present: host/scheme allowlist, deny RFC1918/link-local/
`169.254.169.254` (cloud metadata), disable auto-redirects, resolve-then-validate
DNS. Grep: `http\.(Get|Post)\(.*(c\.Query|req\.)`, `fetch\(.*(req|searchParams)`.

## CSRF — CWE-352

**Already mitigated (do not flag):** cookies `SameSite=Lax` (modern default) or
`Strict`; endpoints authenticated by a custom header / bearer token rather than
ambient cookies; framework anti-CSRF tokens present; Next.js Server Actions (built-in
Origin/same-site check).

**Flag when:** a state-changing, cookie-authenticated endpoint with
`SameSite=None`/unset AND no synchronizer or double-submit token. Fix: a per-session
CSPRNG token in the session + a hidden field/header, compared server-side.

## Open redirect (CWE-601) & path traversal (CWE-22)

```go
c.Redirect(302, c.Query("next"))        // open redirect — flag only if no allowlist + real impact
os.Open(filepath.Join(base, c.Param("file")))  // traversal if no containment check
```

Path traversal fix: `filepath.Clean` then confirm `strings.HasPrefix(resolved,
baseDir)`. *Theoretical open redirects with no demonstrated impact are excluded.*

## Insecure deserialization (CWE-502) & XXE (CWE-611)

- Untrusted data into `gob`, `pickle`, `node-serialize`, `yaml.load` without a safe
  loader → flag.
- Go's `encoding/xml` does **not** resolve external entities by default — not
  classic-XXE-vulnerable; don't flag it. Flag third-party XML libs with DTD/entity
  expansion enabled.

## Security misconfiguration / secrets / CORS (A02:2025)

- **Secrets in code/env (CWE-798):** hardcoded keys/tokens/connection strings, a
  committed `.env`.
- **Verbose errors (CWE-209):** stack traces / DB errors returned to the client —
  `c.JSON(500, gin.H{"error": err.Error()})`. Log server-side, return a generic
  message + request ID.
- **CORS (CWE-942):** `Access-Control-Allow-Origin: *` **with**
  `Allow-Credentials: true` (invalid and dangerous), or reflecting an arbitrary
  `Origin` into ACAO. Grep: `AllowAllOrigins|AllowOrigins.*\*|Access-Control-Allow-Origin`.
  Safe: an explicit origin allowlist.
