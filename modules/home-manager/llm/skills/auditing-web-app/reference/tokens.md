# JWT & OAuth / OIDC

## JWT pitfalls (RFC 8725; CWE-347 improper signature verification)

- **`alg=none`:** the library accepts an unsigned token. Don't consume `none`.
- **Algorithm confusion (RS256→HS256):** attacker flips `alg` to HS256; the
  library verifies with the RSA *public* key as an HMAC secret. **Pin the expected
  algorithm(s) at verification** — never trust the token header's `alg`.
- **Weak HMAC secret:** low-entropy HS256 secret is brute-forceable.
- **Missing/incorrect signature verification:** decoding without verifying.
- **Missing claim validation:** validate **exp**, **aud**, **iss**. Algorithm
  verification is RFC 8725 §3.1; issuer validation is §3.8 and audience is §3.9
  (`iss` prevents token substitution, `aud` prevents cross-service confusion).

This engineer's auth is **Keycloak via `coreos/go-oidc/v3`**, not raw
`jwt.Parse` — so the real footguns are the OIDC verifier's skip flags:

```go
// Bad: skipping the checks the verifier exists to do (seen in seedsn2 auth.go).
verifier := provider.Verifier(&oidc.Config{
    ClientID:          clientID,
    SkipIssuerCheck:   true,   // accepts tokens from any issuer
    SkipClientIDCheck: true,   // no audience binding
    SkipExpiryCheck:   true,   // accepts expired tokens
})
// ... and no nonce check on the auth-code callback (replay).

// Good: let the verifier validate iss/aud/exp; validate nonce on the callback.
verifier := provider.Verifier(&oidc.Config{ClientID: clientID})
idToken, err := verifier.Verify(ctx, rawIDToken)
if idToken.Nonce != expectedNonce { /* reject */ }
```

For the non-Keycloak case (raw golang-jwt v5), pin the algorithm and require
claims:

```go
tok, err := jwt.Parse(s, keyFunc,
    jwt.WithValidMethods([]string{"RS256"}), // else alg confusion / none
    jwt.WithIssuer("https://auth.example.com"),
    jwt.WithAudience("api.example.com"),
    jwt.WithExpirationRequired())
```

Grep: `SkipIssuerCheck`/`SkipClientIDCheck`/`SkipExpiryCheck` set true; a
go-oidc callback with no nonce check; `alg.*none`; `jwt\.Parse\(` without
`WithValidMethods`; configs mixing `HS256` and `RS256`.

False positive: a verifier with the skip flags off (the default) and a pinned
alg is fine — don't flag merely because JWT/OIDC is used.

## OAuth 2.0 / OIDC (RFC 9700 — OAuth Security BCP)

Normative checks:

- **PKCE is mandatory for all client types** (not just SPAs/mobile). The AS must
  reject a downgrade.
- **Authorization Code + PKCE is the default.** Implicit grant SHOULD NOT be used;
  ROPC (password grant) MUST NOT be used.
- **`redirect_uri`: exact string matching** (only exception: localhost port for
  native apps). Flag prefix/substring/regex matching.
- **CSRF on the flow:** `state` parameter or PKCE or OIDC `nonce`.
- **Mix-up defense** with multiple ASes: use `iss` (RFC 9207) or distinct redirect
  URIs.
- **Token handling:** access tokens MUST NOT be passed in URI query params; use
  **303** (not 307) for redirects carrying credentials; audience-restrict access
  tokens.
- **Refresh tokens:** for public clients, rotation or sender-constraining is
  required; on reuse of a rotated (revoked) refresh token, revoke the whole family.

## Session vs token

Server-side sessions: easy revocation, opaque, needs a store. JWTs: stateless,
hard to revoke before `exp` — so keep access-token lifetime short and pair with
refresh rotation. Flag a long-lived (hours/days) access JWT with no revocation
path.
