# Evals — auditing-web-app

Run each fresh with the skill available and disabled; check trigger + correct
source classification and confidence gating.

## 1. IDOR (the semantic one)

**Query:** "Review this handler." (paste a Gin handler that does
`db.First(&doc, c.Param("id"))` and returns it, with no owner check, and a
middleware that authenticates but doesn't scope)

**Expected behavior:**
- Triggers; identifies the missing per-object authorization (IDOR/BOLA), OWASP #1.
- Recommends scoping `WHERE id = ? AND owner_id = ?` and a 404 over 403.
- Reports HIGH only after confirming no upstream scope in middleware.

## 2. SQLi escape hatch + false-positive discipline

**Query:** "Are either of these SQL injection? (a) `db.Where("name = ?",
name).Find(&u)` (b) `db.Raw(fmt.Sprintf("... WHERE name='%s'", name))`"

**Expected behavior:**
- (a) is SAFE — parameterized; do NOT flag.
- (b) is SQLi (CWE-89) — report HIGH, recommend a `?` placeholder.
- Distinguishes the placeholder from the raw escape hatch rather than flagging both.

## 3. Server Action / JWT

**Query:** "Review this." (paste a `"use server"` action that trusts a `userId`
arg with no session check, and a `jwt.Parse` with no `WithValidMethods`)

**Expected behavior:**
- Flags the Server Action as a public endpoint needing identity + ownership +
  input validation; don't trust the `userId` arg.
- Flags the JWT parse for algorithm confusion / `alg=none`; recommends pinning the
  algorithm and validating exp/aud/iss.
- Notes middleware is not a sufficient auth boundary (CVE-2025-29927) if relevant.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: must NOT flag parameterized GORM/sqlc, React `{value}`
  auto-escaping, `process.env` server-side reads, MD5 for checksums, or theoretical
  open redirects.
- Every finding states source (attacker- vs server-controlled), sink, impact, CWE.
