# Nix Language Quick Reference

## Core Concepts
- **Purely functional**: No side effects
- **Lazy evaluation**: Only evaluates what's needed
- **Domain-specific**: Designed for package/system configuration

## Essential Syntax

### inherit
```nix
# Copies variables from scope
inherit (lib) mkIf mkOption types;
# Same as: mkIf = lib.mkIf; mkOption = lib.mkOption; types = lib.types;
```

### Functions
```nix
# Single argument (use attrs for multiple)
myFunc = { name, version ? "1.0" }: "${name}-${version}";
myFunc { name = "hello"; }  # Call
```

### Attribute Sets
```nix
{
  name = "pkg";
  meta.description = "desc";  # Nested
}
```

## Module Pattern
```nix
{ lib, pkgs, config, ... }:
let
  cfg = config.services.myService;
  inherit (lib) mkIf mkOption types;
in {
  options.services.myService = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Applied only when enabled
  };
}
```

## Key lib Functions
- `mkIf`: Conditional config (prevents recursion)
- `mkOption`: Declare options
- `mkDefault/mkForce`: Priority control
- `mkMerge`: Merge attribute sets

## Common Types
- Basic: `bool`, `int`, `str`, `path`
- Containers: `listOf`, `attrsOf`, `submodule`
- Special: `package`, `nullOr`, `either`