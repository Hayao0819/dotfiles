---
name: auditing-web-app
description: >-
  Security audit of web applications — backend implementation and authentication/
  authorization flows — with confidence-gated reporting to keep false positives
  low. Traces attacker-controlled request input (params, body, headers, cookies,
  path) to sinks, distinguishing server-controlled from attacker-controlled, and
  reports HIGH only. Leads with broken access control / IDOR (OWASP #1), then
  injection (and where GORM/sqlc/React are already safe), XSS, SSRF, CSRF, auth
  (password storage, sessions, reset), and tokens (JWT alg confusion, OAuth/OIDC
  PKCE). Framework-aware for Go/Gin/GORM/sqlc and Next.js Server Actions. Use
  when reviewing a web backend, API, route handler, Server Action, or auth flow.
---

# Auditing web applications

A vulnerability-finding reviewer for web apps — backends, APIs, and auth flows —
built on the getsentry security-review model: **investigate before flagging, and
report HIGH only.** The single feature separating a useful review from a noisy
scanner is the source classification — is the input attacker-controlled or
server-controlled? Every finding must answer that.

Lead with **broken access control / IDOR**: it's OWASP #1, it's semantic (grep
won't find it), and the engineer's stack (Gin handlers, Server Actions) is most
exposed there. Injection is largely handled by GORM/sqlc/React defaults — so the
job there is finding the *escape hatches*, not flagging every query.

## Methodology — five steps before flagging

1. Trace data flow from **source** (the request) to **sink** (a dangerous op).
2. Identify the input origin — **server-controlled config vs the request**.
3. Locate validation/sanitization elsewhere in the codebase.
4. Verify framework protections apply (auto-escaping, ORM parameterization).
5. Check middleware/decorators (auth ordering, guards, context propagation).

## Confidence gate — report HIGH only

| Level | Criteria | Action |
|---|---|---|
| **HIGH** | vulnerable pattern **+ attacker-controlled input confirmed** | report with severity + CWE/OWASP |
| **MEDIUM** | vulnerable pattern, input source unclear | note "needs verification" |
| **LOW** | theoretical / best-practice / defense-in-depth | do not report |

*"Do not report issues based solely on pattern matching. Investigate first."*

## Source classification (the core of low false positives)

**Server-controlled — SAFE, not an injection/SSRF source:** `settings.*`/config
values, `os.Getenv`/`process.env` (server-side), config files, hardcoded
constants.

**Attacker-controlled — investigate:** `c.Query`/`c.PostForm`/`c.Param`/
`ShouldBind*`, `request.json()`, Server Action args, `formData`, request body,
most headers, cookies, URL path segments, file uploads (content + names),
**database content written by other users** (stored/second-order), WebSocket
messages.

Canonical pair: `redirect(request.GET['next'])` is vulnerable;
`redirect(settings.LOGIN_URL)` is safe.

## Context routing — load the reference that matches the code

| Code type | Open |
|---|---|
| API routes / handlers | [reference/access-control.md](reference/access-control.md), [reference/injection.md](reference/injection.md) |
| Login / session / password / reset | [reference/auth.md](reference/auth.md) |
| JWT / OAuth / OIDC | [reference/tokens.md](reference/tokens.md) |
| Templates / frontend | [reference/injection.md](reference/injection.md) (XSS) |
| HTTP clients, redirects, file paths, CORS, secrets | [reference/other-vulns.md](reference/other-vulns.md) |
| `.go`/Gin/GORM/sqlc, `.ts`/Next/Server Actions | [reference/frameworks.md](reference/frameworks.md) |

## Always-flag critical patterns

`eval`/`exec`/`Function(userInput)`, `pickle.loads`/untrusted deserialization,
`yaml.load` without a safe loader, `shell=True`/`sh -c` + user input, SQL via
string concatenation, `dangerouslySetInnerHTML`/`v-html`/`innerHTML = userInput`,
and hardcoded secrets (keys, passwords, tokens, private keys).

## Severity

| Severity | Examples |
|---|---|
| Critical | RCE, SQLi, auth bypass, hardcoded secret, JWT `alg=none` |
| High | stored XSS, SSRF-to-metadata, IDOR/BOLA |
| Medium | reflected XSS, CSRF, path traversal |
| Low | missing security headers, verbose errors (defense-in-depth) |

## Do NOT flag (false-positive guards)

- **Parameterized queries / ORM-parameterized calls** (GORM `?`/`@name`, Prisma
  client + `` $queryRaw`...` `` tagged template, Drizzle builder) — safe; only the
  raw escape hatches (`$queryRawUnsafe`, `sql.raw`, `db.Raw`+concat) are sinks.
- **Framework auto-escaping** output: React/JSX `{value}`, Vue `{{value}}`,
  Go `html/template`. The vast majority of interpolation is safe.
- **Server-controlled** values (config/env/constants) reaching a sink.
- Code reachable **only after authentication** — downgrade severity, don't auto-flag.
- **Hashing for non-password use** (checksums, ETags, cache keys) — MD5/SHA-1 is fine there.
- **DoS / resource-exhaustion** as the only issue; **missing rate-limiting** as the
  sole finding; **theoretical open redirects** with no demonstrated impact.
- Test files, dead/commented code.

## What this skill is not

- Not a web-dev tutorial, not a full SAST replacement.
- The **vulnerability** lens. For idiomatic authoring/correctness of the same
  code, that's **writing-go** (Gin/GORM) and **writing-next** (Server Actions) —
  this skill finds bugs; those shape the code.
- Findings go through **natural-writing**: each states the source (attacker- vs
  server-controlled), the sink, why framework protection doesn't apply, the
  impact, and a CWE/OWASP tag. Format `[VULN-NNN]` with Location/Confidence/
  Impact/Evidence/Fix; end clean reviews with "No high-confidence vulnerabilities
  identified."
