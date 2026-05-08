# Nix Flake Task Runner

## Quick Start

```bash
nix run .                        # Deploy all (auto-detect)
nix run . -- <config> switch     # Deploy specific config
nix run .#update                 # Update flake inputs
nix run .#check                  # Run flake validation
nix run .#clean                  # Clean old generations
nix run .#status                 # Show system information
```

## Implementation

Defined in `tasks.nix` as flake apps using `pkgs.writeShellScript`. Each app is a self-contained shell script with no external script dependencies.

## Available Apps

| App | Description |
|-----|-------------|
| `default` / `deploy` | Deploy NixOS + Home Manager |
| `update` | Update all flake inputs |
| `check` | Run `nix flake check` |
| `clean` | Clean generations older than 7 days |
| `status` | Show current system generation info |
