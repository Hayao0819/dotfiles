---
description: Remove an application from NixOS/Home Manager configuration
argument-hint: <app-name> <system-name>
allowed-tools: WebSearch, WebFetch(domain:mynixos.com), WebFetch(domain:discourse.nixos.org), WebFetch(domain:nixos.wiki), WebFetch(domain:github.com), Bash(nix search:*), Bash(nix flake check:*), Read, Edit, Write, Glob, Grep, AskUserQuestion
---

# Remove Application from NixOS Configuration

You are removing the application: **$ARGUMENTS**

Expected format: `<app-name> <system-name>` (e.g., `gnome-logs XPS9350`)

## Step 1: Parse Arguments

Extract from $ARGUMENTS:

- **App name**: The application to remove
- **System name**: Target system (e.g., XPS9350, archlinux)

## Step 2: Research the Application

Use web search to understand the application:

1. Search: "<app-name> nixos package" to find the exact package name
2. Search: "<app-name> what is" to understand its purpose and dependencies
3. Check <https://mynixos.com> for the package details

## Step 3: Locate the Application in the Codebase

Search for where the application is defined:

1. Use Grep to search for the package name across all .nix files
2. Check these common locations:
   - `nixos/<system>/configuration.nix` - System packages
   - `modules/nixos/*/default.nix` - NixOS modules
   - `modules/home-manager/*/default.nix` - Home Manager modules
   - `modules/home-manager/pkgs/global.nix` - Cross-platform CLI tools
   - `modules/home-manager/pkgs/linux.nix` - Linux-only CLI tools

3. Identify WHY the package was installed:
   - Direct user request (in package list)
   - Part of a module (e.g., GNOME module installs GNOME apps)
   - Dependency of another package

## Step 4: Assess Impact

Before removing, determine the scope of changes:

### Scenario A: Single Location

The app is only in one place (e.g., just in configuration.nix packages list)
→ Safe to remove directly

### Scenario B: Part of a Shared Module

The app is in a module used by multiple systems (e.g., `modules/home-manager/gnome/`)
→ **ASK THE USER**: "This app is part of the <module-name> module which is used by: <list systems>. How would you like to proceed?"

Options to present:

1. Remove from the module (affects all systems using it)
2. Create a system-specific override to exclude it
3. Move the app to system-specific config and remove from module

### Scenario C: Dependency of Other Package

The app is pulled in by another package or module
→ **INFORM THE USER**: "This app is a dependency of <parent>. Removing it may break <parent>. Options:"

1. Remove the parent package/module instead
2. Cannot remove (hard dependency)
3. Check if there's a minimal variant without this dependency

## Step 5: Implement the Removal

Based on the assessment:

1. Read the target file(s)
2. Remove the package/configuration following existing patterns
3. If removing from a module:
   - Check if the module becomes empty/useless
   - Clean up any related configuration
4. If the app had its own module directory:
   - Remove the module file
   - Remove the import from the parent `default.nix`

## Step 6: Validate

Run validation after making changes:

```bash
nix flake check --extra-experimental-features 'nix-command flakes'
```

## Reference: Repository Structure

```
nixos/xps9350/configuration.nix          # XPS9350 system config + GUI apps
modules/nixos/<name>/default.nix         # System-level modules
modules/home-manager/pkgs/global.nix     # Cross-platform CLI tools
modules/home-manager/pkgs/linux.nix      # Linux-only CLI tools
modules/home-manager/<name>/default.nix  # Configured applications
```

## Reference: System Names

- **XPS9350**: NixOS system (full OS management)
- **archlinux**: Home Manager on Arch Linux
- **darwin**: macOS via nix-darwin

Now proceed to remove the specified application from the configuration.
