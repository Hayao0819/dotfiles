# Nix Flake Task Runner

## Quick Start

Use the built-in task runner for common operations:

```bash
nix run .                    # Deploy all (auto-detect)
nix run . -- deploy XPS9350  # Deploy specific
nix run . -- nixos           # NixOS only
nix run . -- home            # Home Manager only
nix run . -- update          # Update flake inputs
nix run . -- clean           # Clean old generations
nix run . -- help            # Show all commands
```

## Implementation Pattern

The task runner is implemented in `flake.nix` using the apps output:

```nix
apps.x86_64-linux.default = {
  type = "app";
  program = toString (pkgs.writeShellScript "task-runner" ''
    # Task runner logic here
  '');
};
```

## Available Commands

- `deploy [config]` - Deploy NixOS + Home Manager
- `nixos [config]` - Apply NixOS configuration
- `home [config]` - Apply Home Manager configuration
- `update` - Update all flake inputs
- `check` - Run flake validation
- `clean` - Clean old generations (7 days)
- `status` - Show system information
- `help` - Display help message

## Options

- `--dry-run` - Preview changes without applying
- `--show-trace` - Debug mode with detailed traces
- `--boot` - Apply on next boot (NixOS)

For detailed examples and patterns, see the full documentation in `/docs/guides/`.