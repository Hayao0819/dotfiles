# Injection & XSS

OWASP A05:2025. ORMs and frameworks are safe *by default* — the job is finding the
raw escape hatches. CWE-89 (SQLi), CWE-78 (command), CWE-94 (code), CWE-1336
(SSTI), CWE-79 (XSS).

## SQL injection — find the escape hatches

The engineer's data layers are **GORM** (Go) and **Prisma + Drizzle** (TS) — no
sqlc. So the escape hatches to hunt are GORM raw/clause methods and Prisma/Drizzle
raw.

**Safe (do not flag):** GORM struct/method queries with `?`/`@name` placeholders;
Prisma client queries and the parameterized tagged-template `` $queryRaw`...` ``;
Drizzle query builder. **Not safe:** raw concatenation into `db.Raw`/`db.Exec`
(Go), Prisma **`$queryRawUnsafe`/`$executeRawUnsafe`** and `Prisma.raw(...)`,
Drizzle **`sql.raw(...)`**, and GORM clause methods that take raw SQL fragments
(`Order`, `Group`, `Having`, `Select`, `Distinct`, `Where("…"+x)`).

```ts
// Bad (Prisma): user input concatenated into an Unsafe raw query.
prisma.$queryRawUnsafe(`SELECT * FROM "User" WHERE name = '${name}'`);
// Good: parameterized tagged template (safe) or $queryRawUnsafe with bind params.
prisma.$queryRaw`SELECT * FROM "User" WHERE name = ${name}`;
prisma.$queryRawUnsafe('SELECT * FROM "User" WHERE name = $1', name);
```

```go
// Bad
db.Raw(fmt.Sprintf("SELECT * FROM users WHERE name='%s'", name)).Scan(&u)
db.Where("name = " + name).Find(&users)
db.Order(c.Query("sort")).Find(&users)        // ORDER BY can't be parameterized

// Good
db.Raw("SELECT * FROM users WHERE name = ?", name).Scan(&u)
db.Where("name = ?", name).Find(&users)
// identifiers (column/direction) → allowlist, never parameterize:
allowed := map[string]string{"created": "created_at", "name": "name"}
col, ok := allowed[c.Query("sort")]; if !ok { col = "created_at" }
db.Order(col + " ASC").Find(&users)
```

Grep:
```
db\.(Raw|Exec)\(.*(fmt\.Sprintf|\+|%s)
\.(Where|Order|Group|Having|Select|Distinct)\(\s*fmt\.Sprintf
\$queryRawUnsafe|\$executeRawUnsafe|sql\.raw\(
```

False positive: placeholders carrying user data are SAFE — only the query-string
*fragment* is the sink. Identifiers (table/column/ORDER BY) can't be
parameterized, so they require allowlisting, not a placeholder.

## Command injection (CWE-78)

```go
exec.Command("sh", "-c", userInput)     // Bad: shell + user input
exec.Command("convert", "-resize", size, in, out)  // Good: no shell, arg array
```

Flag `sh -c`/`shell=True`/`child_process.exec(userInput)`. Safe: arg-array exec
with no shell (`exec.Command(bin, args...)`, `execFile`).

## NoSQL / SSTI

- **NoSQL operator injection:** a user-controlled object reaching a query
  (`{ $where: req.body }`, a Mongo filter built from request JSON). Flag when
  request JSON is spread into a filter.
- **SSTI (CWE-1336):** user input into template *source*, not template *data* —
  `template.New(...).Parse(userInput)`. Flag parsing attacker-supplied templates.

## XSS — flag the escape hatches only

| Context | Safe (auto-escaped) | Flag |
|---|---|---|
| React/JSX | `{userInput}` | `dangerouslySetInnerHTML={{__html: x}}` |
| Vue | `{{ x }}`, `v-bind` | `v-html="x"` |
| Go templates | `html/template` (context-aware) | `text/template`, `template.HTML(x)`, `template.JS(x)` |
| Angular | interpolation | `bypassSecurityTrust*`, `[innerHTML]` |
| DOM | `textContent` | `innerHTML`/`outerHTML = x`, `document.write`, `insertAdjacentHTML` |

```tsx
<div>{userComment}</div>                                   // safe — auto-escaped
<div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(userComment)}} />  // if HTML truly needed
```

Grep: `dangerouslySetInnerHTML|v-html|bypassSecurityTrust|template\.(HTML|JS)|text/template|innerHTML\s*=`.

False positive: never flag default-escaped `{value}`/`{{value}}`; `template.HTML`
on a server-controlled constant is safe.
