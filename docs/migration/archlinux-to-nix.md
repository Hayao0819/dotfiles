# Arch Linux to Nix Migration Plan

This document outlines the migration plan from Arch Linux to Nix-managed configuration.

## System Overview

### Source System Information

- **Location**: `/mnt/archlinux`
- **Package Count**: 2,178 packages
- **Home Directory**: `/mnt/archlinux/home/hayao`
- **Desktop Environment**: GNOME

## Installed Packages by Category

### Desktop Environment & GUI

| Category | Packages |
|----------|----------|
| DE | gnome-shell, gnome-session, gnome-control-center, gnome-tweaks, gdm |
| Extensions | dash-to-dock, dash-to-panel, arc-menu, desktop-icons-ng, pano-git |
| Themes | papirus-icon-theme, pop-icon-theme, adw-gtk-theme, kvantum-qt4-git |
| IME | fcitx5, fcitx5-mozc-ut |

### Development Tools

| Category | Packages |
|----------|----------|
| Editors/IDEs | vscode, vscode-insiders, cursor, zed, vim |
| Version Control | git, gitkraken, github-cli, github-copilot-cli |
| Languages | go, rust, ghc, nodejs-lts-jod, python, deno, scala |
| Java | jdk8, jdk17, jdk21, jdk22-graalvm |
| Containers | docker, docker-compose, docker-buildx, lxc |
| Virtualization | qemu-full, virtualbox, libvirt, virt-manager |

### Security & CTF Tools

| Packages |
|----------|
| ghidra, binwalk, john, wireshark, nmap, aircrack-ng, ffuf, wpscan, steghide, sleuthkit, pwndbg, ropgadget |

### 3DS / Embedded Development

| Packages |
|----------|
| devkitARM-r67, 3ds-cmake, 3dstools, tex3ds, libctru, citro2d, citro3d |

### Media & Creative

| Packages |
|----------|
| audacity, inkscape, krita, obs-studio, vlc, retroarch, steam |

### Office & Utilities

| Packages |
|----------|
| libreoffice-fresh, onlyoffice, drawio, thunderbird, brave, google-chrome, firefox-developer-edition |

## Current Nix Configuration Status

### Already Configured (linux.nix + global.nix)

```
docker-compose, volta, claude-code, aria2, jq, wget, git-lfs,
markdownlint-cli, shfmt, shellcheck, fd, bat, btop, gping,
fastfetch, procs, ripgrep, tealdeer, topgrade, gnupg, nil, nixpkgs-fmt
```

### Home Manager archlinux Configuration

- User: hayao
- stateVersion: 24.11
- systemd.user.startServices enabled

## Migration Plan

### Phase 1: Foundation (Priority: High)

1. **Shell Environment**
   - Verify and migrate zsh/fish configuration
   - Verify sheldon (zsh plugin manager) settings

2. **GNOME Settings**
   - Migrate dconf settings to `dconf-generated.nix`
   - Manage themes and extensions via Home Manager

3. **Git Configuration**
   - Migrate `.gitconfig` to `programs.git`

### Phase 2: Development Environment (Priority: High)

1. **Additional Packages (linux.nix)**

   ```nix
   # Editors
   pkgs.vscode
   pkgs.zed-editor

   # Languages & Runtimes
   pkgs.go
   pkgs.rustup
   pkgs.nodejs_22
   pkgs.python3
   pkgs.deno

   # Utilities
   pkgs.gh
   pkgs.act  # GitHub Actions local runner
   pkgs.mise # Version manager
   ```

2. **Containers & Virtualization**
   - Docker managed via NixOS module (existing)
   - QEMU/libvirt configured at NixOS level

### Phase 3: GUI Applications (Priority: Medium)

```nix
# Browsers
pkgs.brave
pkgs.google-chrome
pkgs.firefox-devedition

# Office
pkgs.libreoffice
pkgs.thunderbird

# Media
pkgs.vlc
pkgs.audacity
pkgs.inkscape
pkgs.obs-studio

# Communication
pkgs.vesktop
pkgs.slack
pkgs.zoom-us
```

### Phase 4: Specialized Tools (Priority: Low)

1. **Security Tools**

   ```nix
   pkgs.ghidra
   pkgs.wireshark
   pkgs.nmap
   pkgs.john
   ```

2. **3DS Development Environment**
   - devkitPro is difficult to package in Nix
   - Consider Overlay or FHS environment approach

### Phase 5: Configuration Files Migration

| Source | Destination |
|--------|-------------|
| `.gitconfig` | `programs.git` |
| `.bashrc` / `.zshrc` | `programs.zsh` / `programs.bash` |
| GNOME dconf | `dconf.settings` |
| fcitx5 | `i18n.inputMethod.fcitx5` |
| gtk theme | `gtk.theme` |

## Recommended Actions

### Immediate (Can add now)

- brave, vscode, vlc, libreoffice, thunderbird, go, rustup

### Requires Configuration Migration

- GNOME dconf, fcitx5, git

### Needs Investigation

- devkitARM (requires custom package/Overlay)

### On Hold

- Some AUR packages (may not exist in Nix)

## Full Package List Reference

The complete list of installed Arch Linux packages is available at:
`/tmp/arch-packages.txt` (generated during analysis)

To regenerate:

```bash
ls /mnt/archlinux/var/lib/pacman/local/ | sed 's/-[0-9].*$//' | sort -u
```
