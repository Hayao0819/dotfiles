# Authentication & sessions

OWASP A07:2025. CWE-287, CWE-384 (fixation), CWE-307 (brute force), CWE-640 (reset).

## Password storage (OWASP Password Storage Cheat Sheet)

| Algorithm | Parameters | Status |
|---|---|---|
| **Argon2id** (primary) | m=19456 (19 MiB), t=2, p=1 minimum | recommended |
| **scrypt** | N=2^17, r=8, p=1 | if no Argon2id |
| **bcrypt** (legacy) | cost ≥ 10; **72-byte input limit** — pre-hash long inputs | legacy |
| **PBKDF2** (FIPS) | HMAC-SHA256: 600,000 iters | compliance only |

**Forbidden for passwords:** MD5, SHA-1, **plain SHA-256/512** — fast hashes are
brute-forceable. (MD5/SHA for checksums is fine — don't flag that.)

```go
// Bad
hash := sha256.Sum256([]byte(password))
// Good
hash, _ := argon2id.CreateHash(password, argon2id.DefaultParams)  // or bcrypt cost>=10
```

Grep: `md5\.|sha1\.|sha256\.Sum.*pass`.

## Session management

- Cookie flags: **HttpOnly** (blocks XSS theft), **Secure**, **SameSite=Lax/Strict**.
  Flag a session cookie missing `HttpOnly`/`Secure`.
- **Session fixation (CWE-384):** rotate the session ID **on login** and on
  privilege change. Flag a login flow that keeps the pre-auth session ID.
- Session ID: CSPRNG, sufficient entropy; idle + absolute timeout; server-side
  invalidation on logout.

```go
// Good: regenerate the session on authentication.
session.Regenerate()      // new ID after verifying credentials
session.Set("uid", user.ID)
```

## Account enumeration

Identical responses and timing for "user not found" vs "wrong password", and the
same for registration and password reset ("if the account exists, we sent an
email"). Flag a login/reset that reveals which accounts exist.

## Brute force / credential stuffing (CWE-307)

Missing rate limiting **as the only issue is excluded** — but flag a login / reset
/ MFA endpoint with no lockout **combined with** account enumeration or weak
password policy.

## Password reset (CWE-640)

The reset token must be: high-entropy CSPRNG, **single-use**, **short expiry**,
invalidated after use or password change. The flow must not leak account
existence, and the token must not land in a logged URL or a `Referer`-leakable
position.

```ts
// Bad: predictable, long-lived, reusable token in a logged URL.
const token = user.id + "-" + Date.now();
// Good: CSPRNG, hashed at rest, short TTL, single-use.
const token = crypto.randomBytes(32).toString("hex");
await db.resetToken.create({ userId, tokenHash: sha256(token), expiresAt: in15min });
```
