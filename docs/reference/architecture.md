# Architecture

## Directory Structure

```txt
├── flake.nix              # Main entry point (flake-parts)
├── modules/
│   ├── common/            # Shared modules (nixpkgs config)
│   ├── nixos/             # NixOS modules (system/, user/)
│   ├── home-manager/      # Home Manager modules
│   └── darwin/            # macOS modules
├── nixos/                 # NixOS machine configs
│   ├── XPS9350/
│   ├── WSL/
│   └── Installer/
├── home-manager/          # Home Manager configs
│   ├── archlinux/
│   ├── debian/
│   ├── linux/
│   ├── darwin/
│   └── wsl/
├── darwin/                # nix-darwin configs
│   └── MacBook/
├── pkgs/                  # Custom packages
├── overlays/              # Nixpkgs overlays
└── tasks.nix              # Flake apps (deploy, check, etc.)
```

## Auto-Import

All `modules/` and machine config directories use `readDir` with pipe-operators for automatic module discovery. Adding a new module only requires creating a directory with `default.nix` — no index file edits needed.

## Configuration Patterns

### Machine Configurations

Each machine: `nixos/<Machine>/configuration.nix` imports hardware settings + shared modules.

### Module System

Reusable configs in `modules/` are auto-imported and can be enabled/disabled via options.

### Platform Separation

- **NixOS**: Full OS management
- **Home Manager**: User environment (non-NixOS Linux)
- **Darwin**: macOS via nix-darwin

## Adding Configurations

### New NixOS Machine

1. Create `nixos/<Name>/configuration.nix` and `hardware-configuration.nix`
2. Auto-imported — no need to edit `nixos/default.nix`
3. `sudo nixos-rebuild switch --flake .#<Name>`

### New Home Manager Config

1. Create `home-manager/<name>/default.nix`
2. Auto-imported — no need to edit index files
3. `nix run home-manager -- switch --flake .#<name>`
