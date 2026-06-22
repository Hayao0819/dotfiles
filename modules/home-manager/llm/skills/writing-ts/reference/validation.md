# Validation at boundaries

The type system vanishes at runtime. Every place untyped data enters the program
is a boundary that must be *parsed*, not cast. This codebase uses **zod**
(exclusively, 10 projects). The schema is the single source of truth; the static
type is derived from it.

## Parse, don't validate

```ts
import { z } from "zod";

// Bad: cast trusts the wire. One malformed payload and `user.email` is undefined
// at runtime while TS swears it's a string.
const user = (await req.json()) as User;

// Good: parse once at the edge into a typed, validated value.
const User = z.object({
  id: z.uuid(),
  email: z.email(),          // zod 4: top-level format helpers, better tree-shaking
  age: z.number().int().min(0),
});
type User = z.infer<typeof User>; // derive the type — never hand-write a parallel interface

const user = User.parse(await req.json()); // throws ZodError on bad input
```

Boundaries that need parsing: HTTP request bodies and query params, `process.env`
(parse it once at boot), `JSON.parse` results, `localStorage`, message-queue
payloads, third-party API responses, form data.

## parse vs safeParse

```ts
// .parse — throws ZodError. Use for fail-fast where a throw is correct.
const env = Env.parse(process.env); // crash at boot if config is wrong — good

// .safeParse — returns a result you handle. Use at user-facing boundaries.
const result = Login.safeParse(formData);
if (!result.success) {
  return { errors: z.treeifyError(result.error) }; // show field errors, don't throw
}
doLogin(result.data);
```

Rule of thumb: `.parse` when a failure is a bug or a boot-time misconfiguration;
`.safeParse` when a failure is expected input you render gracefully (forms, APIs).

## Schema-derived types, both directions

```ts
const Form = z.object({ name: z.string(), count: z.coerce.number() });
type FormInput = z.input<typeof Form>;   // before coercion (count: unknown from a form)
type FormOutput = z.output<typeof Form>; // after parse (count: number)
```

Use `z.input` for what the form/wire sends, `z.output` (= `z.infer`) for the
parsed value. They differ whenever you use `.coerce`, `.default`, or
`.transform`.

## zod 4 notes

- zod 4 is the current major (the codebase is mid-migration v3→v4). It's ~7–15×
  faster than v3 and far cheaper on `tsc` instantiations — the old "zod is huge
  and slow" complaint is a v3 artifact.
- Use top-level format validators: `z.email()`, `z.uuid()`, `z.url()`. The chained
  forms (`z.string().email()`) are **deprecated** in zod 4, not merely
  dispreferred — flag them. `ZodError.format()`/`.flatten()` are likewise
  deprecated in favor of `z.treeifyError()`.
- Reach for `zod/mini` (≈1.9 kB) before considering another library when bundle
  size on the edge matters.

## When another library fits (a choice, not the default)

zod is the established default. The alternatives trade ecosystem for size or
speed — note them, but don't switch unilaterally (this is a [stack.md](stack.md)
decision):

| | zod 4 | valibot 1.x | arktype 2.x |
|---|---|---|---|
| API | chaining | modular pipes (tree-shakes to <1 kB) | TS-string syntax |
| Strength | ecosystem, RHF resolver, default | smallest bundle (edge, forms) | fastest validation, hot paths |
| Cost | larger than valibot | smaller ecosystem | heavy `tsc` cost on big schemas |

All three implement Standard Schema, so resolvers (`@hookform/resolvers`) and
tools accept any of them. The reason to stay on zod is the ecosystem, not lock-in.
