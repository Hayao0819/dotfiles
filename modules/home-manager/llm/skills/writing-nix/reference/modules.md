# Module system

Modules (NixOS, Home Manager, Darwin) share one shape in this repo: a header, an
`options` declaration, and a `config` gated by an enable toggle.

## The shape

```nix
{ config, pkgs, lib, ... }:
let
  cfg = config.myFeature; # alias in larger modules
in
{
  options.myFeature = {
    enable = lib.mkEnableOption "my feature";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.something.port = cfg.port;
  };
}
```

Conventions to match: `lib.mkEnableOption` for booleans, `lib.mkOption { type =
lib.types.*; default; description; }` for the rest, `lib.*` written
fully-qualified in the body (no `with lib;`), `config = lib.mkIf cfg.enable
{...}` as the dominant gating pattern.

## mkIf, mkMerge, and priorities

- **`mkIf` wraps the config *value*, not the `options` block.** A common bug is
  conditionalizing the wrong thing.
- **`mkMerge`** composes several conditional blocks into one config — the idiom
  for optional sub-features:

```nix
config = lib.mkMerge [
  (lib.mkIf cfg.enable { home.packages = [ pkgs.base ]; })
  (lib.mkIf (cfg.enable && cfg.extras) { home.packages = [ pkgs.extra ]; })
];
```

- **Priorities** resolve conflicting definitions (lower number wins):
  `mkOptionDefault` 1500, `mkDefault` 1000, a **plain/direct definition 100**
  (`defaultOverridePriority`), `mkForce` 50. So a direct assignment silently
  overrides an `mkDefault` (100 beats 1000) with no conflict; **two plain
  definitions** (both 100) are what throw a conflict error. Use `mkDefault` for a
  value a host may override, `mkForce` to win unconditionally.

## Optional package lists

`with pkgs;` scoped to a single list is accepted local style here:

```nix
home.packages =
  with pkgs;
  [ git ripgrep ]
  ++ lib.optionals cfg.gui [ firefox ]
  ++ lib.optionals cfg.osint.enable [ amass ];
```

`lib.optionals cond [ ... ]` (note the `s`) appends a list only when `cond` holds.

## Avoiding infinite recursion

A module may branch its `imports` or `options` on static inputs, but **never on
`config`** — `config` isn't known until the module system has finished evaluating
the options, so reading it to decide what to import loops. Gate behavior in
`config = mkIf ...`, not in `imports`.

## Assertions and warnings

Use the `assertions` and `warnings` options (evaluator-checked) to fail or warn
on invalid combinations rather than letting a bad config build something broken.
