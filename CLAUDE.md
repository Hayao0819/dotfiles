# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## IMPORTANT: Mandatory Syntax Check After Every Change

**ALWAYS** run the following command after making ANY changes to Nix files to ensure syntax validity:

```bash
nix flake check --extra-experimental-features 'nix-command flakes'
```

This command MUST be executed:
- After editing any `.nix` file
- After adding new modules or configurations
- Before committing any changes
- As the final step of any task involving Nix files

If the check fails, immediately fix the syntax errors before proceeding. The output "all checks passed!" indicates success.

## IMPORTANT: Auto-Update Documentation When Learning New Nix Information

When you discover new or updated information about Nix through web searches, official documentation, or problem-solving during this session, you MUST automatically update this CLAUDE.md file without being asked. This includes:

- New Nix commands, options, or flags
- Updated best practices or recommended patterns
- New module options or deprecations
- Fixes for common issues not yet documented here
- New tools or workflows in the Nix ecosystem
- Corrections to any outdated information in this document

**How to update:**
1. Add the new information to the appropriate section of this document
2. If no suitable section exists, create a new one
3. Include the date of the update as a comment if the information is time-sensitive
4. Ensure the information is accurate and verified before adding

This ensures the documentation stays current and useful for future sessions.

## Repository Overview

This is a Nix-based dotfiles repository that manages system configurations for NixOS, macOS (via nix-darwin), and other Linux distributions through Home Manager. The repository uses Nix Flakes for declarative and reproducible system management.

## Common Commands

### Development Environment
```bash
# Enter development shell with required tools (nil, nixd, nixpkgs-fmt, git)
nix-shell

# Format Nix files
nix fmt
```

### NixOS System Management
```bash
# First time installation (creates new boot entry)
sudo nixos-rebuild boot --flake .#Inspiron5490
sudo nixos-rebuild boot --flake .#XPS9350

# Apply configuration changes (current session)
sudo nixos-rebuild switch --flake .#Inspiron5490

# Build ISO installer
nix build .#nixosConfigurations.Installer.config.system.build.isoImage
```

### Home Manager
```bash
# Apply home configuration for Arch Linux
nix run github:nix-community/home-manager -- switch --flake .#archlinux

# For stable/unstable variants (from remote)
nix run github:nix-community/home-manager -- switch --flake github:Hayao0819/dotfiles/nix#hayao@stable
nix run github:nix-community/home-manager -- switch --flake github:Hayao0819/dotfiles/nix#hayao@unstable
```

### Darwin (macOS)
```bash
# Apply darwin configuration
nix run github:nix-community/home-manager -- switch --flake .#darwin-stable
nix run github:nix-community/home-manager -- switch --flake .#darwin-unstable
```

## Architecture

### Directory Structure
- **`flake.nix`**: Main entry point defining all outputs (nixosConfigurations, homeConfigurations, darwinConfigurations)
- **`modules/`**: Reusable configuration modules
  - `nixos/`: NixOS-specific modules (bootloader, GNOME, network, locale)
  - `home-manager/`: Home Manager modules (packages, shell, Git, VS Code, wallpapers)
  - `darwin/`: macOS-specific modules
- **`nixos/`**: Machine-specific NixOS configurations
  - `inspiron5490/`: Dell Inspiron 5490 configuration
  - `xps9350/`: Dell XPS 9350 configuration
- **`home/`**: Home Manager configurations by platform
  - `linux/`: Generic Linux home configuration
  - `archlinux/`: Arch Linux specific home configuration
  - `darwin/`: macOS home configuration
- **`pkgs/`**: Custom package definitions
- **`overlays/`**: Nixpkgs overlays

### Key Configuration Patterns

1. **Machine Configurations**: Each physical machine has its own NixOS configuration in `nixos/<machine>/configuration.nix` that imports hardware-specific settings and common modules.

2. **Module System**: Configurations are modularized for reusability. Modules in `modules/` can be imported by any configuration and typically provide options that can be enabled/disabled.

3. **Platform Separation**: The repository handles three platforms:
   - NixOS systems (full OS management)
   - Home Manager on non-NixOS Linux (user environment only)
   - Darwin/macOS systems (via nix-darwin)

4. **Flake Structure**: The `flake.nix` orchestrates all configurations:
   - Inputs: nixpkgs (stable 24.11), nixpkgs-unstable, home-manager, nix-darwin
   - Outputs: nixosConfigurations, homeConfigurations, darwinConfigurations, custom modules

### Adding New Configurations

To add a new NixOS machine:
1. Create `nixos/<machine-name>/configuration.nix` and `hardware-configuration.nix`
2. Add entry in `nixos/default.nix`
3. Rebuild with `sudo nixos-rebuild switch --flake .#<machine-name>`

To add a new Home Manager configuration:
1. Create configuration in `home/<platform>/`
2. Add entry in `home/default.nix`
3. Apply with `nix run home-manager -- switch --flake .#<config-name>`

## Nix Language Fundamentals

### Core Language Concepts

Nix is a **domain-specific, purely functional, lazily evaluated, dynamically typed** programming language designed for creating and composing derivations (build descriptions).

#### Key Syntax Elements

**inherit keyword**: Copies variables from one scope to another
```nix
# Instead of writing:
let lib = pkgs.lib; mkIf = lib.mkIf; mkOption = lib.mkOption; in

# Use inherit:
inherit (lib) mkIf mkOption types;
```

**Attribute Sets**: Core data structure in Nix
```nix
{
  name = "mypackage";
  version = "1.0";
  meta.description = "A description";  # Nested attributes
}
```

**Functions**: All functions are single-argument (use attribute sets for multiple parameters)
```nix
# Function definition
myFunc = { name, version ? "1.0" }: "${name}-${version}";

# Function call
myFunc { name = "hello"; }
```

**Derivations**: The fundamental building block for packages
```nix
derivation {
  name = "myname";
  builder = "mybuilder";
  system = "x86_64-linux";
}
```

### Module System Patterns

#### Standard Module Structure
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
      description = "Enable my service";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.mypackage;
      description = "Package to use";
    };
  };

  config = mkIf cfg.enable {
    # Configuration only applied when enabled
    systemd.services.myService = {
      # ...
    };
  };
}
```

#### Essential `lib` Functions

- **mkIf**: Conditional configuration (prevents infinite recursion)
  ```nix
  config = mkIf cfg.enable { /* ... */ };
  ```

- **mkOption**: Declare configurable options
  ```nix
  mkOption { type = types.str; default = "value"; }
  ```

- **mkDefault**: Set low-priority defaults (can be overridden)
- **mkForce**: High-priority override
- **mkBefore/mkAfter**: List ordering
- **mkMerge**: Merge multiple attribute sets

#### Common Types (`lib.types`)

- Basic: `bool`, `int`, `str`, `path`
- Containers: `listOf`, `attrsOf`, `submodule`
- Special: `package`, `nullOr`, `either`, `oneOf`
- Custom validation: `addCheck`

## Best Practices and Patterns

### Flake Best Practices (2024-2025)

1. **Structure**: Keep flakes self-contained with explicit inputs
2. **Version Pinning**: Use `follows` to avoid version mismatches
   ```nix
   inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
   ```
3. **Updates**: Run `nix flake update` to update all inputs

### Module Composition

1. **Separation of Concerns**: System config vs user config (Home Manager)
2. **Modularization**: Break configurations into reusable modules
3. **Override Priorities**: Use mkDefault < normal < mkForce

### Home Manager Integration

**As NixOS Module** (recommended for NixOS):
- Configuration applies with `nixos-rebuild switch`
- No separate home-manager commands needed

**Standalone** (for non-NixOS):
- Independent of system configuration
- Applied with `home-manager switch`

## Common Issues and Troubleshooting

### Syntax Validation Commands

Always validate changes using these commands:

1. **Full flake check** (MANDATORY after every change):
   ```bash
   nix flake check --extra-experimental-features 'nix-command flakes'
   ```

2. **Specific configuration validation**:
   ```bash
   # Validate NixOS configuration without building
   nix eval --extra-experimental-features 'nix-command flakes' .#nixosConfigurations.Inspiron5490.config.system.build.toplevel --apply 'x: null'

   # Validate Home Manager configuration
   nix eval --extra-experimental-features 'nix-command flakes' .#homeConfigurations.archlinux.activationPackage --apply 'x: null'

   # Dry-run build (checks derivation without building)
   nix build --dry-run --extra-experimental-features 'nix-command flakes' .#homeConfigurations.archlinux.activationPackage
   ```

3. **Format check**:
   ```bash
   # Check formatting (doesn't modify files)
   nix fmt --extra-experimental-features 'nix-command flakes' -- --check

   # Auto-format files
   nix fmt --extra-experimental-features 'nix-command flakes'
   ```

### Infinite Recursion

**Causes**:
- Circular references in modules
- Using package attributes in `nixpkgs.config`
- Incorrect use of `config` values without `mkIf`

**Solutions**:
- Always use `mkIf` for conditional configuration
- Use `--show-trace` for debugging: `nix build --show-trace`
- Check for circular module dependencies

### Attribute Not Found

**Common fixes**:
- Verify imports in flake.nix
- Check module paths and dependencies
- Use `:p options.<option>.declarationPositions` in nix repl

### Debugging Tools

```bash
# Show detailed error traces
nix flake check --show-trace

# Debug specific builds
nix build --show-trace .#nixosConfigurations.hostname

# Find option declarations
nix repl
:l <nixpkgs>
:p options.networking.hostName.declarationPositions

# Clean old packages
nix-collect-garbage -d

# Force rebuild (bypass cache)
nixos-rebuild switch --flake .#hostname --option eval-cache false
```

### Error Handling in Modules

```nix
# Assertions with meaningful errors
{ config, lib, ... }:
{
  config = lib.mkIf config.myOption {
    assertions = [{
      assertion = config.otherOption != null;
      message = "myOption requires otherOption to be set";
    }];
  };
}
```

## File System Mounts

### Basic Mount Configuration

Use `fileSystems` to mount partitions at boot:
```nix
fileSystems."/mnt/data" = {
  device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
  fsType = "ext4";  # or btrfs, ntfs, exfat, etc.
};
```

### Device Identification Best Practices

Always use topology-independent device paths to avoid issues when hardware changes:
- `/dev/disk/by-uuid/` - Most reliable, doesn't change
- `/dev/disk/by-label/` - Uses filesystem label

Find UUIDs with: `lsblk -f` or `ls -la /dev/disk/by-uuid/`

### Common Mount Options

```nix
fileSystems."/mnt/external" = {
  device = "/dev/disk/by-uuid/...";
  fsType = "btrfs";
  options = [
    "nofail"       # Don't fail boot if mount fails (recommended for external/optional drives)
    "users"        # Allow any user to mount/unmount
    "x-gvfs-show"  # Show in file managers like GNOME Nautilus
  ];
};
```

### Btrfs Subvolumes

```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/...";
  fsType = "btrfs";
  options = [ "subvol=@" ];
};

fileSystems."/home" = {
  device = "/dev/disk/by-uuid/...";
  fsType = "btrfs";
  options = [ "subvol=@home" ];
};
```

### Important Notes

- Mount points are created automatically if they don't exist
- System startup fails if any mount fails (use `nofail` option for non-critical mounts)
- Changes require `nixos-rebuild switch` to take effect

## Important Gotchas

1. **Lazy Evaluation**: Nix only evaluates what's needed - use `mkIf` to control evaluation
2. **String Interpolation**: `"${expression}"` evaluates to store paths for derivations
3. **Reproducibility**: Flakes ensure bit-for-bit reproducible builds
4. **Atomicity**: Failed builds don't affect the current system
5. **Pure Evaluation**: Flakes can't access environment variables or non-declared inputs