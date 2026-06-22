# Evals — writing-nix

Run each fresh with the skill available and disabled; check trigger + output.

## 1. Auto-discovery convention

**Query:** "I'm adding a new home-manager module for `foo`. Here's my plan." (user
describes creating `modules/home-manager/foo/default.nix` AND editing the parent
`default.nix` to import it)

**Expected behavior:**
- Triggers on the Nix task and recognizes the flake-parts/auto-discovery layout.
- Tells the user NOT to edit the aggregator — the `readDir |> ... |> listToAttrs`
  pipeline registers the directory automatically.
- Reminds them to `git add` the new file (flakes ignore untracked files).

## 2. Packaging idiom

**Query:** "Review this package." (paste a `stdenv.mkDerivation rec { version =
...; src = fetchFromGitHub { rev = version; ... }; sha256 = "0x..."; }`)

**Expected behavior:**
- Recommends `finalAttrs:` over `rec` (so `overrideAttrs` of `version` updates
  `src`), matching the repo's newest packages.
- Recommends SRI `hash = "sha256-...";` over legacy base32 `sha256`.
- Doesn't flag the scoped `with lib;` in a `meta` block as wrong.

## 3. Module + anti-patterns

**Query:** "Anything off here?" (paste a module with `config = { ... }` not gated
by `mkIf`, a top-level `with import <nixpkgs> {};`, and `a // b` merging nested
attrs)

**Expected behavior:**
- Recommends `config = lib.mkIf cfg.enable { ... }`.
- Flags the unscoped top-level `with` and the `<nixpkgs>` lookup path.
- Flags `//` as a shallow merge → `lib.recursiveUpdate` for nested attrs.
- Reminds to run `nix fmt` + `nix flake check` after the change.

## Notes

- Test on Haiku, Sonnet, Opus.
- Regression watch: the skill must NOT flag the repo's deliberate scoped `with`
  usages (`with builtins;` in aggregators, `with pkgs;` in a list) as errors.
- Should fire for `.nix` files and flake/module/package work.
