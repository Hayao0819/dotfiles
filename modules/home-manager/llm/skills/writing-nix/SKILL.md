---
name: writing-nix
description: >-
  Idiomatic Nix review and authoring matched to THIS engineer's flake-parts
  dotfiles conventions. Covers the readDir-pipe auto-discovery module layout,
  the NixOS/Home Manager/Darwin module system (mkOption/mkEnableOption, mkIf/
  mkMerge/mkDefault, options/config split), packaging with finalAttrs and SRI
  hashes, override vs overrideAttrs, the nix.dev anti-patterns, and the nixfmt/
  statix/deadnix toolchain. Use when writing or reviewing Nix — flake.nix, a
  module default.nix, an overlay, a package, home-manager/NixOS/darwin config —
  in this repo or another flake. Knows to ALWAYS validate with nix flake check
  and format with nix fmt after a .nix change.
---

# Writing Nix

A reviewer tuned to this engineer's established flake conventions, not generic
Nix advice. The dotfiles repo is a `flake-parts` flake for NixOS + Home Manager +
nix-darwin with an auto-discovery module layout; this skill mimics that style and
flags regressions. Where the upstream nix.dev rulebook conflicts with the repo's
deliberate local style, the repo wins (and the skill says so).

> Compatibility: flakes + `nix-command` + **`pipe-operators`** (`|>`) — all three
> are still **experimental** in Nix as of mid-2026 (pipe-operators is load-bearing
> here, so the flag is mandatory on every invocation). `pkgs.nixfmt` (Haskell) is
> the official RFC-166 formatter; this repo deliberately uses the separate Rust
> `pkgs.nixfmt-rs` via `nix fmt` (they are distinct packages, not aliases). After
> any `.nix` change: format, then
> `nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'`.

## When to use

- Writing or reviewing any `.nix`: `flake.nix`, a module `default.nix`, an
  overlay, a `pkgs/*` derivation, a NixOS/Home-Manager/Darwin config.
- Adding an app/module/package (and respecting the no-index-edit auto-import rule).

## How to read this skill

| Open this | When |
|---|---|
| [reference/flake-structure.md](reference/flake-structure.md) | flake-parts layout, the readDir-pipe auto-discovery idiom, inputs/follows |
| [reference/modules.md](reference/modules.md) | options/config, mkOption/mkEnableOption, mkIf/mkMerge/priorities |
| [reference/packaging.md](reference/packaging.md) | finalAttrs, SRI hashes, callPackage, override vs overrideAttrs, overlays |
| [reference/anti-patterns.md](reference/anti-patterns.md) | the nix.dev anti-patterns + what this repo does differently on purpose |

## This repo's conventions (mimic these)

- **flake-parts.** `flake.nix` is a thin dispatcher: `flake-parts.lib.mkFlake`
  with a `flake = {...}` block for system-agnostic outputs and `perSystem` for
  per-system ones. Outputs split into top-level dirs (`modules/`, `nixos/`,
  `pkgs/`, `overlays/`, `home-manager/`, …), each a `default.nix` taking
  `{ inputs }` or `{ inputs, outputs }`.
- **Auto-discovery, never edit an index.** Aggregators use the `readDir |>
  attrNames |> filter (≠ default.nix) |> map import |> listToAttrs` pipeline.
  Adding a module/host/package means creating a directory with a `default.nix` —
  do **not** add it to an index file. → [reference/flake-structure.md](reference/flake-structure.md)
- **Module shape:** `modules/<layer>/<category>/<name>/default.nix`, header
  `{ config, pkgs, lib, ... }:`, an explicit `options`/`config` split,
  `lib.mkEnableOption` for toggles, `config = lib.mkIf cfg.enable { ... }`, a
  `cfg = config.<name>` alias in larger modules. Write `lib.*` fully-qualified in
  module bodies (no `with lib;`). → [reference/modules.md](reference/modules.md)
- **Packaging:** new derivations use the `finalAttrs:` pattern and SRI
  `hash = "sha256-...";`; `writeShellApplication` for script packages; overlays
  named (`additions`, `modifications`, `unstable-packages`) with `final: prev:`.
  → [reference/packaging.md](reference/packaging.md)
- **Deliberate local style** (don't "fix" these): `with builtins;` atop the
  readDir aggregators, and `with pkgs;` / `with lib;` scoped to a package list or
  `meta` block. These coexist with the nix.dev "avoid `with`" rule by being
  tightly scoped. → [reference/anti-patterns.md](reference/anti-patterns.md)

## Highest-leverage review checks

- **Adding something must not touch an index file.** If a change edits a
  `default.nix` aggregator to register a new module/package, that's wrong — the
  readDir pipeline already picks it up. → [reference/flake-structure.md](reference/flake-structure.md)
- **`mkIf` wraps the config value, not the options.** And two definitions at the
  same priority conflict — use `mkDefault` (1000) / `mkForce` (50) to resolve, and
  `mkMerge` to compose conditional blocks. → [reference/modules.md](reference/modules.md)
- **New packages use `finalAttrs:`, not `rec`** — so an `overrideAttrs` that
  changes `version` correctly updates a `src` built from it. SRI `hash =`, not
  legacy `sha256 = "0x...";`. → [reference/packaging.md](reference/packaging.md)
- **`overrideAttrs` (patch the derivation) vs `override` (swap a dependency
  arg)** — pick the right one; prefer `overrideAttrs` for src/flags/phases.
- **Reproducibility:** no `builtins.currentTime`, no `<nixpkgs>` lookup paths, no
  `--impure`; flakes only see git-tracked files (a new untracked file is invisible
  to `nix flake check`). → [reference/anti-patterns.md](reference/anti-patterns.md)
- **`nativeBuildInputs` (build-time tools) vs `buildInputs` (runtime libs)** — the
  wrong split silently breaks cross-compilation.

## Validation pass (after every .nix change — repo rule)

```sh
nix fmt        # nixfmt-rs via the flake formatter
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
# new files must be git-added first — flakes ignore untracked files
statix check   # anti-pattern linter (in the devshell)
deadnix        # dead-code (unused bindings/args)
```

## What this skill is not

- Not a Nix-language tutorial, and not a restatement of `statix`/`deadnix`. Route
  mechanical lint to the tool.
- It defers to the repo's deliberate style over generic nix.dev rules where they
  conflict — the scoped `with` usages are intentional.
- Prose it helps you write (docs, module `description`s) goes through
  **natural-writing**.
