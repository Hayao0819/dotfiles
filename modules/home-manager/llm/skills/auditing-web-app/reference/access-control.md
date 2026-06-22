# Broken access control / IDOR

OWASP #1 (2021 and 2025). The highest-yield class and the hardest to find — it's
**semantic**, not pattern-based: you confirm a handler fetches or mutates a
resource by ID without an ownership/role check. CWE-639 (IDOR), CWE-862 (missing
authz), CWE-863 (incorrect authz), CWE-285, CWE-915 (mass assignment).

## The checklist

- **Per-object (BOLA/IDOR):** does the query scope to the caller? `WHERE id = ?`
  alone is broken; it needs `AND owner_id = ?` or tenant scoping.
- **Vertical (BFLA):** admin/privileged routes guarded by a *role* check, not just
  authentication.
- **Mass assignment:** binding the whole request body into a persisted model lets a
  user set `role`/`is_admin`/`owner_id`.
- **Forced browsing:** unlinked-but-reachable privileged endpoints.

## IDOR + mass assignment (Go/Gin/GORM)

```go
// Bad: fetch by id with no owner check (IDOR); bind whole body (mass assignment).
func GetDoc(c *gin.Context) {
    var d Doc
    db.First(&d, c.Param("id"))        // any user reads any doc
    c.JSON(200, d)
}
func Update(c *gin.Context) {
    var d Doc
    c.ShouldBindJSON(&d)               // user can set d.OwnerID / d.Role
    db.Save(&d)
}

// Good: scope to the authenticated user; bind a DTO / Select an allowlist.
func GetDoc(c *gin.Context) {
    uid := c.MustGet("userID").(uint)
    var d Doc
    if err := db.Where("id = ? AND owner_id = ?", c.Param("id"), uid).
        First(&d).Error; err != nil {
        c.AbortWithStatus(404)         // 404 not 403 — avoid enumeration
        return
    }
    c.JSON(200, d)
}
func Update(c *gin.Context) {
    var in UpdateDocDTO                // only the fields a user may set
    if err := c.ShouldBindJSON(&in); err != nil { c.AbortWithStatus(400); return }
    uid := c.MustGet("userID").(uint)
    db.Model(&Doc{}).
        Where("id = ? AND owner_id = ?", c.Param("id"), uid).
        Select("title", "body").Updates(in)   // allowlist columns
}
```

## Server Actions (Next.js) — same rule, public endpoint

```ts
"use server";
export async function deletePost(rawId: string) {
  const id = z.string().uuid().parse(rawId);     // validate FIRST, before any DB use
  const session = await auth();
  if (!session) throw new Error("unauthenticated");                 // identity
  const post = await db.post.findUnique({ where: { id } });
  if (post?.authorId !== session.user.id) throw new Error("forbidden"); // ownership
  await db.post.delete({ where: { id } });
}
```

## Grep

```
ShouldBind(JSON)?\(&\w+\)        # Go mass-assignment candidate
data:\s*req\.(body|json)          # Prisma/Drizzle mass assignment
First\(&\w+,\s*c\.Param           # fetch-by-id — check for a nearby owner scope
```

## False positive

If an upstream middleware already enforces tenant/owner scope and propagates a
scoped `*gorm.DB` or `userID` through context, the handler may be safe — verify
the context propagation (methodology step 5) before flagging. A correct role
middleware on the route group covers vertical authz.
