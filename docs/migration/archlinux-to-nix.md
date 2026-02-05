# Arch Linux to Nix Migration Plan

This document outlines the migration plan from Arch Linux to Nix-managed configuration.

## System Overview

### Source System Information

- **Location**: `/mnt/archlinux`
- **Total Packages**: 2,169 packages
- **Explicitly Installed**: 371 packages
- **Home Directory**: `/mnt/archlinux/home/hayao`
- **Desktop Environment**: GNOME

### Package List Commands

```bash
# List all packages from mounted Arch system
ls /mnt/archlinux/var/lib/pacman/local/ | grep -v ALPM | sed 's/-[0-9].*$//' | sort -u

# List explicitly installed packages (no REASON or REASON=0)
bash -c 'for pkg in /mnt/archlinux/var/lib/pacman/local/*/desc; do
  reason=$(grep -A1 "^%REASON%$" "$pkg" 2>/dev/null | tail -1)
  if [ -z "$reason" ] || [ "$reason" = "0" ]; then
    grep -A1 "^%NAME%$" "$pkg" | tail -1
  fi
done' | sort -u
```

## Migration Status

### Completed (Configured in NixOS)

| Category | Packages | Location |
|----------|----------|----------|
| **Desktop Environment** | GNOME Shell, GDM, gnome-tweaks, dconf-editor | `modules/nixos/gnome` |
| **Shell** | zsh, fish, bat, btop, fastfetch, ripgrep | `modules/home-manager/zsh`, `pkgs` |
| **Development CLI** | git, gh, docker, docker-compose, shellcheck, shfmt | Various modules |
| **Fonts** | noto-fonts, noto-fonts-cjk, noto-fonts-emoji, IPA fonts, Nerd Fonts | `modules/nixos/fonts` |
| **IME** | fcitx5-mozc-ut | `modules/nixos/locale` |
| **Virtualization** | QEMU/KVM, libvirt, virt-manager, VirtualBox, LXC | `modules/nixos/virtualization` |
| **Browsers** | brave, google-chrome, firefox | `nixos/xps9350/configuration.nix` |
| **Communication** | vesktop, slack | `nixos/xps9350/configuration.nix` |
| **Media** | vlc, spotify | `nixos/xps9350/configuration.nix` |
| **Development GUI** | vscode-fhs, gitkraken | `nixos/xps9350/configuration.nix` |
| **System Tools** | mission-center | `nixos/xps9350/configuration.nix` |
| **Gaming** | bottles (Wine manager) | `nixos/xps9350/configuration.nix` |
| **GNOME Extensions** | arcmenu, dash-to-panel, ding, gsconnect, appindicator, kimpanel, copyous | `modules/nixos/gnome` |
| **Icon Theme** | papirus-icon-theme | `modules/nixos/gnome` |

### In Progress (Partially Configured)

| Item | Status | Notes |
|------|--------|-------|
| dconf settings | Mostly done | Some settings need manual sync |
| Pano → Copyous | Migration done | Need to remove pano from enabled-extensions |

### Not Yet Migrated (371 Explicit Packages)

#### High Priority - Daily Use

| Arch Package | Nix Package | Status |
|--------------|-------------|--------|
| thunderbird | `pkgs.thunderbird` | **Not configured** |
| libreoffice-fresh | `pkgs.libreoffice` | **Not configured** |
| obs-studio | `pkgs.obs-studio` | **Not configured** |
| audacity | `pkgs.audacity` | **Not configured** |
| inkscape | `pkgs.inkscape` | **Not configured** |
| krita | `pkgs.krita` | **Not configured** |
| drawio-desktop | `pkgs.drawio` | **Not configured** |
| zed | `pkgs.zed-editor` | **Not configured** |
| cursor-bin | N/A (AppImage) | Needs FHS or custom derivation |
| zoom | `pkgs.zoom-us` | **Not configured** |
| mattermost-desktop | `pkgs.mattermost-desktop` | **Not configured** |

#### Development Tools

| Arch Package | Nix Package | Status |
|--------------|-------------|--------|
| go | `pkgs.go` | **Not configured** |
| rust | `pkgs.rustup` | **Not configured** |
| ghc + haskell-language-server | `pkgs.ghc`, `pkgs.haskell-language-server` | **Not configured** |
| scala + gradle | `pkgs.scala`, `pkgs.gradle` | **Not configured** |
| act | `pkgs.act` | **Not configured** |
| mise | `pkgs.mise` | **Not configured** |
| pyenv | `pkgs.pyenv` | **Not configured** |
| uv | `pkgs.uv` | **Not configured** |
| python-poetry | `pkgs.poetry` | **Not configured** |
| gdb | `pkgs.gdb` | **Not configured** |
| clang | `pkgs.clang` | **Not configured** |
| graphviz | `pkgs.graphviz` | **Not configured** |
| supabase | `pkgs.supabase-cli` | **Not configured** |
| litestream | `pkgs.litestream` | **Not configured** |
| postgresql | `pkgs.postgresql` | **Not configured** (service) |

#### Security / CTF Tools

| Arch Package | Nix Package | Status |
|--------------|-------------|--------|
| ghidra | `pkgs.ghidra` | **Not configured** |
| nmap | `pkgs.nmap` | **Not configured** |
| john | `pkgs.john` | **Not configured** |
| wireshark-qt | `pkgs.wireshark` | **Not configured** |
| binwalk | `pkgs.binwalk` | **Not configured** |
| aircrack-ng | `pkgs.aircrack-ng` | **Not configured** |
| ffuf | `pkgs.ffuf` | **Not configured** |
| steghide | `pkgs.steghide` | **Not configured** |
| sleuthkit | `pkgs.sleuthkit` | **Not configured** |
| pwndbg | `pkgs.pwndbg` | **Not configured** |
| testdisk | `pkgs.testdisk` | **Not configured** |
| jadx | `pkgs.jadx` | **Not configured** |
| wpscan | `pkgs.wpscan` | **Not configured** |
| wordlists | `pkgs.wordlists` | **Not configured** |

#### System / Hardware Tools

| Arch Package | Nix Package | Status |
|--------------|-------------|--------|
| gparted | `pkgs.gparted` | **Not configured** |
| baobab | `pkgs.baobab` | **Not configured** |
| htop | `pkgs.htop` | **Not configured** |
| nvtop | `pkgs.nvtop` | **Not configured** |
| tlp + tlpui | `services.tlp` | **Not configured** |
| snapper + snapper-gui | `pkgs.snapper` | **Not configured** |
| cups (printing) | `services.printing` | Enabled in common.nix |

#### Media / 3D Printing

| Arch Package | Nix Package | Status |
|--------------|-------------|--------|
| retroarch | `pkgs.retroarch` | **Not configured** |
| steam | `pkgs.steam` | **Not configured** |
| qsynth | `pkgs.qsynth` | **Not configured** |
| sonic-visualiser | `pkgs.sonic-visualiser` | **Not configured** |
| openscad | `pkgs.openscad` | **Not configured** |
| orca-slicer | N/A | Needs custom derivation |
| creality-print | N/A | AppImage |

#### Network / VPN

| Arch Package | Nix Package | Status |
|--------------|-------------|--------|
| networkmanager-openconnect | `pkgs.networkmanager-openconnect` | **Not configured** |
| networkmanager-openvpn | `pkgs.networkmanager-openvpn` | **Not configured** |
| globalprotect-openconnect | `pkgs.globalprotect-openconnect` | **Not configured** |
| cloudflared | `pkgs.cloudflared` | **Not configured** |
| tigervnc | `pkgs.tigervnc` | **Not configured** |
| filezilla | `pkgs.filezilla` | **Not configured** |
| speedtest-cli | `pkgs.speedtest-cli` | **Not configured** |

#### Misc Utilities

| Arch Package | Nix Package | Status |
|--------------|-------------|--------|
| tree | `pkgs.tree` | **Not configured** |
| lsd | `pkgs.lsd` | **Not configured** |
| hyperfine | `pkgs.hyperfine` | **Not configured** |
| zellij | `pkgs.zellij` | **Not configured** |
| yt-dlp | `pkgs.yt-dlp` | **Not configured** |
| transmission-gtk | `pkgs.transmission-gtk` | **Not configured** |
| ventoy-bin | `pkgs.ventoy` | **Not configured** |
| rpi-imager | `pkgs.rpi-imager` | **Not configured** |
| etcher-bin | N/A | Use rpi-imager instead |
| aws-cli | `pkgs.awscli2` | **Not configured** |
| sl | `pkgs.sl` | **Not configured** |

### Not Available in Nixpkgs (Needs Custom Solution)

| Arch Package | Solution |
|--------------|----------|
| devkitARM, 3ds-cmake, libctru, citro2d, citro3d | FHS environment or custom overlay |
| cursor-bin | AppImage/FHS wrapper |
| visual-studio-code-insiders-bin | Use vscode or custom derivation |
| creality-print-appimage | AppImage wrapper |
| orca-slicer | Custom derivation |
| intel-ipu7-* | Already configured in ipu7.nix |
| linux-sgx-driver-hayao-dkms-git | Custom derivation needed |
| kvantum-qt4-git | May not be needed on GNOME |
| qcma-git (PS Vita) | Custom derivation |
| miraktest | Custom derivation |

### Explicitly Excluded (Arch-specific or Not Needed)

- `base`, `base-devel` - NixOS has its own base
- `yay`, `pacman-contrib`, `reflector` - Arch package managers
- `archiso`, `arch-install-scripts` - Arch installation tools
- `*-keyring`, `*-mirrorlist` - Arch repository keys
- `devtools`, `devtools-alterlinux` - Arch package building
- `grub2-theme-*`, `plymouth-theme-*` - Using systemd-boot
- `lightdm-*`, `nody-greeter` - Using GDM
- Various `xorg-*` tools - NixOS manages X automatically

## Recommended Next Steps

### Immediate Actions

1. **Apply uncommitted changes**
   ```bash
   nix flake check
   sudo nixos-rebuild switch --flake .
   ```

2. **Add commonly used packages** to `configuration.nix`:
   ```nix
   users.users.hayao.packages = with pkgs; [
     # Office
     libreoffice
     thunderbird

     # Media
     audacity
     inkscape
     obs-studio

     # Development
     go
     rustup
     ghc
   ];
   ```

3. **Enable Steam** (requires configuration):
   ```nix
   programs.steam.enable = true;
   ```

### Medium Priority

1. Add security/CTF tools to a separate module
2. Configure TLP for laptop power management
3. Add NetworkManager VPN plugins

### Low Priority

1. Create FHS environment for devkitPro/3DS development
2. Package custom AUR tools as Nix derivations
3. Set up PostgreSQL service if needed

## Full Explicit Package List

See [archlinux-packages.md](./archlinux-packages.md) for the complete list of 371 explicitly installed packages.
