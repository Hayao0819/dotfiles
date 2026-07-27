---
name: remove-app
description: Removes an application from NixOS or Home Manager configuration. Locates all references, assesses impact on shared modules, and safely removes.
when_to_use: When the user asks to remove, uninstall, or delete an application or package from their Nix configuration.
argument-hint: <app-name>
allowed-tools: WebSearch, WebFetch(domain:mynixos.com), Bash(nix search:*), Bash(nix flake check:*), Read, Edit, Write, Glob, Grep, AskUserQuestion
---

# Remove Application: **$ARGUMENTS**

## 1. Locate

Use Grep to find all references to the package across `.nix` files:

- `nixos/*/configuration.nix` — System packages
- `modules/nixos/*/default.nix` — NixOS modules
- `modules/home-manager/*/default.nix` — Home Manager modules
- `modules/home-manager/pkgs/global.nix` — Cross-platform CLI
- `modules/home-manager/pkgs/linux.nix` — Linux-only CLI

## 2. Assess Impact

- **Single location**: Safe to remove directly
- **Shared module**: Ask the user — the module may be used by multiple systems
- **Dependency**: Inform the user if removing it would break another package

## 3. Remove

1. Remove the package/configuration
2. If the app had its own module directory, delete it (auto-import handles the rest)
3. Clean up related config (environment variables, services, etc.)

## 4. Validate

```bash
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
```
