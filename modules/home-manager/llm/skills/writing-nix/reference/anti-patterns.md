# Anti-patterns

The nix.dev canonical list, plus the places this repo deliberately departs from
it (don't "fix" those).

## nix.dev anti-patterns

| Mistake | Problem | Fix |
|---|---|---|
| `with (import <nixpkgs> {}); ...` at file top | unclear scoping, breaks static analysis, name capture | `let inherit (pkgs) curl jq; in ...` |
| `rec { a = a; }` | infinite recursion via shadowing | `let ... in` |
| `<nixpkgs>` lookup path | depends on `$NIX_PATH`, non-reproducible | declare deps explicitly / flake inputs |
| `import <nixpkgs> {}` | reads impure `~/.config/nixpkgs` | `import nixpkgs { config = {}; overlays = []; }` |
| `a // b` for nested attrs | `//` is a **shallow** merge — drops nested keys | `lib.recursiveUpdate` |
| `src = ./.;` | store path depends on the parent dir name → spurious rebuilds | `builtins.path { path = ./.; name = "src"; }` |
| unquoted URL | legacy syntax; statix flags it | quote it |
| `builtins.currentTime` / `--impure` | non-reproducible | avoid; use proper inputs |
| IFD (import-from-derivation) | pauses eval to realise a build — slow | avoid in hot eval paths |

## Where THIS repo departs on purpose

The "avoid `with`" rule is about an unscoped `with` at file top that pollutes the
namespace. This repo uses `with` only **tightly scoped**, which is fine and is
established style — don't flag these:

- `with builtins;` atop the readDir auto-discovery aggregators (so `readDir`,
  `attrNames`, `filter`, `listToAttrs` read clean). See
  [flake-structure.md](flake-structure.md).
- `with pkgs;` scoped to a single package-list expression
  (`with pkgs; [ git ripgrep ] ++ lib.optionals ...`).
- `with lib;` scoped to a `meta = with lib; { ... };` block in a derivation.

Module *bodies* still write `lib.*` fully-qualified — keep that distinction.

## Formatting and the treefmt.toml caveat

- The official formatter is **nixfmt (RFC 166)** = `pkgs.nixfmt` (the Haskell
  impl, 1.x); `nixfmt-rfc-style` is now a deprecated alias for it. `pkgs.nixfmt-rs`
  is a **separate** package — an independent Rust reimplementation (0.4.x) aiming
  for byte-identical output, **not** an alias of `pkgs.nixfmt`. This repo
  deliberately wires `nixfmt-rs` as the flake `formatter`, run via `nix fmt`.
  `nixpkgs-fmt` is archived and `alejandra` is no longer the standard — don't reach
  for either.
- The root `treefmt.toml` is an **unmodified upstream template stub** — not the
  repo's real formatter config, and nothing wires treefmt in any `.nix`. So the
  repo's `CLAUDE.md` instruction to run bare `treefmt` is effectively a **no-op**;
  the working path is `nix fmt` → `nixfmt-rs`. Flag this contradiction and prefer
  `nix fmt` (or wire treefmt-nix properly and fix CLAUDE.md).
- `statix check` (anti-pattern lint: `bool_comparison`, `manual_inherit`,
  `legacy_let_syntax`, `unquoted_uri`, …) and `deadnix` (unused bindings/args) are
  in the devshell — run them before committing.
