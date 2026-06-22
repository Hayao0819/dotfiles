# Flake structure

This repo uses **flake-parts**, not flake-utils or raw flakes. flake-parts
expresses outputs through the module system, so a misplaced output (a
system-agnostic `overlays` accidentally nested under a system) is a typed error
instead of a silent malformed attr — the reason it's preferred for a multi-target
config. (Small single-package repos elsewhere use flake-utils; that split is
fine.)

## The dispatcher

`flake.nix` stays thin — it wires inputs and imports each top-level directory:

```nix
{
  outputs = inputs @ { self, flake-parts, ... }:
    let outputs = self; in # `self` must come from the args, not be referenced bare
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      flake = {
        # system-agnostic outputs: nixosConfigurations, overlays, modules, ...
      };
      perSystem = { pkgs, system, ... }: {
        formatter = pkgs.nixfmt-rs;
        # packages, devShells, checks, apps
      };
    };
}
```

`inherit inputs outputs` is threaded into each sub-`default.nix`, which takes
`{ inputs }` or `{ inputs, outputs, ... }`.

## The auto-discovery pipeline (the signature idiom)

Every aggregator builds its attrset by reading the directory — adding a child
directory is all it takes to register a new module/host/package:

```nix
{ inputs }:
with builtins;
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (mod: {
  name = mod;
  value = import "${inputs.self}/modules/${mod}" { inherit inputs; };
})
|> listToAttrs
```

Consequences for review:

- **Never edit an aggregator to register a new entry.** If a diff adds a module
  and also edits the parent `default.nix` to list it, the edit is wrong — the
  pipeline already discovers it. Create the directory with a `default.nix`, done.
- `|>` (pipe-operators) is **required** — it's enabled in
  `experimental-features`, `NIX_CONFIG`, and every `nix flake check` invocation in
  this repo. Don't write a change that assumes it's unavailable.
- `with builtins;` atop these aggregators is deliberate local style (gives
  `readDir`/`attrNames`/`filter`/`listToAttrs` unqualified). Don't "fix" it.

## Inputs and follows

- Every input that itself depends on nixpkgs gets
  `inputs.<x>.inputs.nixpkgs.follows = "nixpkgs"` to dedupe the dependency tree —
  this repo does it on every input; keep doing it.
- `flake.lock` pins exact revisions; flakes evaluate in pure mode and **only see
  git-tracked files** — a newly created module that isn't `git add`ed is invisible
  to `nix flake check`. This is the most common "my change does nothing" footgun.
- Mirror flake inputs into the legacy registry/`nixPath` (as
  `modules/nixos/system/nixpkgs` does) so `nix shell nixpkgs#x` resolves to the
  pinned nixpkgs.

## Host wiring

Hosts import modules by attrpath (`outputs.modules.nixos.system.<name>`,
`outputs.modules.nixos.user.<name>`), not raw file paths, plus
`inputs.<flake>.nixosModules.default` for external flakes. `inputs`, `outputs`,
and `hostname` arrive via `specialArgs`.
