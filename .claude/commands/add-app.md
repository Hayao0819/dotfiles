---
description: Add a new application to NixOS/Home Manager configuration
argument-hint: <app-name>
allowed-tools: WebSearch, WebFetch(domain:mynixos.com), WebFetch(domain:discourse.nixos.org), WebFetch(domain:nixos.wiki), WebFetch(domain:github.com), Bash(nix search:*), Bash(nix flake check:*), Read, Edit, Write, Glob, Grep
---

# Add Application to NixOS Configuration

You are adding the application: **$ARGUMENTS**

## Step 1: Research the Application

Search for how to install and configure "$ARGUMENTS" on NixOS or Home Manager:

1. Search Google for: "$ARGUMENTS nixos home-manager install configuration"
2. Check <https://mynixos.com> for the package and available options
3. Determine:
   - Package name in nixpkgs (e.g., `pkgs.google-chrome`, `pkgs.firefox`)
   - Whether it has a Home Manager module (e.g., `programs.git`, `programs.vscode`)
   - Whether it needs NixOS-level configuration (system services, hardware, bootloader)

## Step 2: Determine the Appropriate Layer

Based on your research, categorize the application:

### Category A: NixOS System-Level (bootloader, services, hardware)

Examples: grub, systemd-boot, docker daemon, nvidia drivers, networking
→ Add to: `modules/nixos/<module-name>/default.nix` or `nixos/xps9350/configuration.nix`

### Category B: GUI Desktop Applications (user-scoped)

Examples: Chrome, Firefox, Slack, VS Code, Discord
→ Add to: `nixos/xps9350/configuration.nix` in `users.users.hayao.packages`

### Category C: CLI Tools (cross-platform)

Examples: ripgrep, jq, git, nodejs
→ Add to: `modules/home-manager/pkgs/global.nix`

### Category D: CLI Tools (Linux-only)

Examples: docker-compose, dconf2nix
→ Add to: `modules/home-manager/pkgs/linux.nix`

### Category E: Configured Applications (with Home Manager module)

Examples: git (with config), zsh (with plugins), neovim (with settings)
→ Create: `modules/home-manager/<app-name>/default.nix`
→ Add import to: `modules/home-manager/default.nix`

## Step 3: Implement

1. Read the target file(s) first
2. Add the package/configuration following existing patterns
3. If creating a new module:
   - Create `modules/home-manager/<app-name>/default.nix` or `modules/nixos/<app-name>/default.nix`
   - Add to the corresponding `default.nix` index file
4. For complex configurations, split into multiple files if needed

## Step 4: Validate

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

Now proceed to add "$ARGUMENTS" to the appropriate location.
