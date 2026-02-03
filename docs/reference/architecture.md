# Architecture

## Directory Structure

```txt
├── flake.nix          # Main entry point
├── modules/
│   ├── nixos/         # NixOS modules
│   ├── home-manager/  # Home Manager modules
│   └── darwin/        # macOS modules
├── nixos/             # Machine configs
│   └── xps9350/
├── home/              # Home configs
│   ├── linux/
│   ├── archlinux/
│   └── darwin/
├── pkgs/              # Custom packages
└── overlays/          # Nixpkgs overlays
```

## Configuration Patterns

### Machine Configurations

Each machine: `nixos/<machine>/configuration.nix` imports hardware settings + common modules

### Module System

Reusable configs in `modules/` can be imported and enabled/disabled via options

### Platform Separation

- **NixOS**: Full OS management
- **Home Manager**: User environment (non-NixOS Linux)
- **Darwin**: macOS via nix-darwin

## Adding Configurations

### New NixOS Machine

1. Create `nixos/<name>/configuration.nix` and `hardware-configuration.nix`
2. Add to `nixos/default.nix`
3. `sudo nixos-rebuild switch --flake .#<name>`

### New Home Manager Config

1. Create in `home/<platform>/`
2. Add to `home/default.nix`
3. `nix run home-manager -- switch --flake .#<name>`
