---
name: add-app
description: Adds a new application to NixOS or Home Manager configuration. Researches the package, determines the appropriate installation layer, implements it, and validates.
when_to_use: When the user asks to install, add, or set up a new application or package in their Nix configuration.
argument-hint: <app-name>
allowed-tools: WebSearch, WebFetch(domain:mynixos.com), WebFetch(domain:discourse.nixos.org), WebFetch(domain:nixos.wiki), WebFetch(domain:github.com), Bash(nix search:*), Bash(nix flake check:*), Read, Edit, Write, Glob, Grep
---

# Add Application: **$ARGUMENTS**

## 1. Research

1. Search for "$ARGUMENTS nixos home-manager" on the web
2. Check <https://mynixos.com> for package name and available options
3. Determine: package name in nixpkgs, whether a Home Manager module exists, whether it needs system-level config

## 2. Determine Installation Layer

| Category | Examples | Target |
|----------|----------|--------|
| NixOS system-level | docker daemon, nvidia, bootloader | `modules/nixos/<name>/default.nix` |
| GUI desktop apps | Chrome, VS Code, Discord | `nixos/XPS9350/configuration.nix` → `users.users.hayao.packages` |
| Cross-platform CLI | ripgrep, jq, nodejs | `modules/home-manager/pkgs/global.nix` |
| Linux-only CLI | dconf2nix | `modules/home-manager/pkgs/linux.nix` |
| Configured apps | git (with config), zsh (with plugins) | `modules/home-manager/<name>/default.nix` |

New modules are auto-imported via `readDir` — no need to edit `default.nix` index files.

## 3. Implement

1. Read the target file
2. Add package/config following existing patterns
3. For new modules, create `modules/home-manager/<name>/default.nix` or `modules/nixos/<name>/default.nix`

## 4. Validate

```bash
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
```
