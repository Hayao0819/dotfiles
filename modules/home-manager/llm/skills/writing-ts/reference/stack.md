# The stack

These are the libraries this engineer actually uses, measured across ~29 JS/TS
projects in `~/Git` (2026-06). Default to the established choice; don't introduce
a competitor without a reason. The recency anchors for "current preference" are
the most recently active projects: ayaka, tomoru, payment-app, hayao0819.com.

## De-facto choices (one clear winner — just use it)

| Category | Choice | Evidence |
|---|---|---|
| Framework | **Next.js, App Router, `src/` dir** | 16 projects; App Router dominant |
| React | **React 19** | current default; 18 is legacy |
| UI components | **shadcn/ui** (radix-ui + `components.json`) + **lucide-react** icons | 11 projects |
| Styling | **Tailwind CSS** + `cva` + `clsx` + `tailwind-merge` | 17 projects |
| Client state | **jotai** | 11 projects |
| Forms | **react-hook-form** + `@hookform/resolvers` | 9 projects |
| Validation | **zod** (see [validation.md](validation.md)) | 10 projects, exclusive |
| Package manager | **pnpm** (+ `turbo` for monorepos) | 17 projects |
| Unit test | **vitest**; **playwright** for E2E | when tests exist |
| Dates / charts / toasts / theming | date-fns, recharts, sonner, next-themes | broadly used |

When building UI, compose shadcn/ui primitives with `cva` for variants; don't pull
in MUI/Chakra/Mantine (MUI exists only in the older seedsn/user-registration
cluster and is being left behind).

## Version migrations in progress

The recent projects have moved; older ones haven't. Prefer the newer in new code:

- **Tailwind v4** (CSS-first config, `@tailwindcss/postcss`) over v3.
- **zod v4** over v3.
- **Next 16 / React 19** over 14–15 / React 18.
- **TS strict on** — only the legacy Pages-Router cluster (seedsn, seedsn2,
  user-registration) has `strict: false`; new code is strict.

## Decided defaults (confirmed by the engineer)

These were split in the codebase; the engineer has settled them. Use the default
in new code; the older form is a migration target, not a precedent.

- **Lint/format: Biome** — standardize new projects on Biome (v2). Keep
  typescript-eslint only for the type-checked rules Biome can't do yet (see
  [tsconfig-tooling.md](tsconfig-tooling.md)). Don't start a new project on
  ESLint+Prettier.
- **Auth: better-auth** — the default for new Next apps (the newest project's
  choice). Auth.js v5 and custom JWT exist in older code; don't propagate them.
- **Client state: jotai by default; zustand is fine for larger apps** — reach for
  zustand when a single store with actions fits a big app better; otherwise jotai.

## Still a choice — present both, don't assume

- **Data fetching / RPC — context-dependent (by design).** An integrated Next app
  defaults to RSC + Server Actions with *no* client fetch library (13 of 16 apps).
  A separate-backend app or a Vite SPA uses TanStack Query (and Hono RPC where the
  backend is Hono). Pick by the architecture in front of you, not a single rule.
- **ORM.** drizzle leads (3), with supabase-client and prisma also present. Small
  sample — a soft preference; confirm per project.
