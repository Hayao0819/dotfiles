# Missing Packages: Arch Linux vs NixOS XPS9350

Comparison of packages installed on Arch Linux vs current NixOS XPS9350 configuration.

## Currently Configured in NixOS

### System Packages (configuration.nix)

- firefox-bin
- vesktop
- brave
- google-chrome
- slack
- vlc
- spotify
- gitkraken
- vscode-fhs
- mission-center
- bottles

### GNOME Module

- dconf-editor
- gnome-tweaks
- papirus-icon-theme
- gnomeExtensions.appindicator
- gnomeExtensions.gsconnect
- gnomeExtensions.dash-to-panel
- gnomeExtensions.kimpanel
- gnomeExtensions.status-icons
- gnomeExtensions.user-themes
- gnomeExtensions.pano
- gnomeExtensions.desktop-icons-ng-ding
- gnomeExtensions.arcmenu

### Home Manager - Global (global.nix)

- aria2
- jq
- wget
- git-lfs
- markdownlint-cli
- shfmt
- shellcheck
- fd
- bat
- btop
- gping
- fastfetch
- procs
- ripgrep
- tealdeer
- topgrade
- gnupg
- nil
- nixpkgs-fmt

### Home Manager - Linux (linux.nix)

- docker-compose
- pinentry-gnome3
- dconf2nix
- volta
- claude-code

### Services Enabled

- Docker
- CUPS (printing)
- PipeWire (audio)
- GDM
- GNOME Desktop
- gnome-keyring
- GPG agent with SSH support

---

## Missing from NixOS (High Priority)

### Input Method (Japanese)

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| fcitx5 | `i18n.inputMethod.fcitx5.enable` | NixOS module |
| fcitx5-mozc-ut | `fcitx5-mozc` | |
| fcitx5-gtk | included | |
| fcitx5-qt | included | |
| fcitx5-configtool | `fcitx5-configtool` | |

### Development - Languages

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| go | `pkgs.go` | |
| rust | `pkgs.rustup` or `pkgs.rustc` | |
| deno | `pkgs.deno` | |
| ghc | `pkgs.ghc` | |
| python (+ packages) | `pkgs.python3` | |
| nodejs-lts-jod | `pkgs.nodejs_22` | |
| scala | `pkgs.scala` | |
| jdk17-openjdk | `pkgs.jdk17` | |
| jdk21-openjdk | `pkgs.jdk21` | |

### Development - Tools

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| github-cli | `pkgs.gh` | |
| act | `pkgs.act` | GitHub Actions local |
| mise | `pkgs.mise` | Version manager |
| hadolint-bin | `pkgs.hadolint` | Dockerfile linter |
| cppcheck | `pkgs.cppcheck` | |
| gdb | `pkgs.gdb` | |
| hyperfine | `pkgs.hyperfine` | Benchmarking |

### Editors

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| zed | `pkgs.zed-editor` | |
| cursor-bin | Not in nixpkgs | Needs overlay/flake |
| visual-studio-code-insiders-bin | Not in nixpkgs | |

### Office & Productivity

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| libreoffice-fresh | `pkgs.libreoffice` | |
| thunderbird | `pkgs.thunderbird` | |
| onlyoffice-bin | `pkgs.onlyoffice-bin` | |
| drawio-desktop | `pkgs.drawio` | |
| evince | `pkgs.evince` | PDF viewer |

### Media

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| audacity | `pkgs.audacity` | |
| obs-studio | `pkgs.obs-studio` | |
| inkscape | `pkgs.inkscape` | |
| krita | `pkgs.krita` | |
| imagemagick | `pkgs.imagemagick` | |
| ffmpeg | `pkgs.ffmpeg` | |
| yt-dlp | `pkgs.yt-dlp` | |

### Communication

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| mattermost-desktop | `pkgs.mattermost-desktop` | |
| zoom | `pkgs.zoom-us` | |

### System Tools

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| htop | `pkgs.htop` | |
| lsd | `pkgs.lsd` | ls replacement |
| tree | `pkgs.tree` | |
| ncdu | `pkgs.ncdu` | Disk usage |
| nvtop | `pkgs.nvtopPackages.full` | GPU monitor |
| parallel | `pkgs.parallel` | |
| progress | `pkgs.progress` | |
| rsync | `pkgs.rsync` | |
| unzip | `pkgs.unzip` | |

### Networking

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| filezilla | `pkgs.filezilla` | |
| nmap | `pkgs.nmap` | |
| traceroute | `pkgs.traceroute` | |
| speedtest-cli | `pkgs.speedtest-cli` | |
| cloudflared | `pkgs.cloudflared` | |
| openvpn | `pkgs.openvpn` | |

### Fonts (Japanese)

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| noto-fonts-cjk | `pkgs.noto-fonts-cjk-sans` | |
| noto-fonts-emoji | `pkgs.noto-fonts-emoji` | |
| otf-ipaexfont | `pkgs.ipaexfont` | |
| ttf-sourcecodepro-nerd | `pkgs.nerd-fonts.source-code-pro` | |

---

## Missing from NixOS (Medium Priority)

### Virtualization

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| qemu-full | `virtualisation.libvirtd` | NixOS module |
| virt-manager | `pkgs.virt-manager` | |
| virtualbox | `virtualisation.virtualbox.host` | NixOS module |

### Gaming

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| steam | `programs.steam.enable` | NixOS module |
| retroarch | `pkgs.retroarch` | |
| wine | `pkgs.wine` | |
| winetricks | `pkgs.winetricks` | |

### Security/CTF Tools

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| ghidra | `pkgs.ghidra` | |
| wireshark-qt | `pkgs.wireshark` | |
| binwalk | `pkgs.binwalk` | |
| john | `pkgs.john` | |
| aircrack-ng | `pkgs.aircrack-ng` | |
| nmap | `pkgs.nmap` | |
| ffuf | `pkgs.ffuf` | |
| steghide | `pkgs.steghide` | |

### 3D Printing

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| orca-slicer | `pkgs.orca-slicer` | |
| openscad | `pkgs.openscad` | |

### Other Utilities

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| gparted | `pkgs.gparted` | |
| baobab | `pkgs.baobab` | Disk analyzer |
| simple-scan | `pkgs.simple-scan` | |
| transmission-gtk | `pkgs.transmission_4-gtk` | |
| rpi-imager | `pkgs.rpi-imager` | |
| ventoy-bin | Not in nixpkgs | |

---

## Missing from NixOS (Low Priority / Special)

### 3DS Development

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| devkitARM-r67 | Not in nixpkgs | Requires FHS env |
| 3dstools | Not in nixpkgs | |
| tex3ds | Not in nixpkgs | |
| libctru | Not in nixpkgs | |

### PS Vita

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| qcma-git | Not in nixpkgs | |
| libvitamtp-git | Not in nixpkgs | |

### Haskell (full environment)

| Arch Package | Nix Package | Notes |
|--------------|-------------|-------|
| haskell-language-server | `pkgs.haskell-language-server` | |
| hlint | `pkgs.hlint` | |
| stack | `pkgs.stack` | |

### Proprietary / AUR

| Arch Package | Notes |
|--------------|-------|
| cursor-bin | Cursor IDE - needs flake |
| visual-studio-code-insiders-bin | Needs overlay |
| binaryninja-free | Reverse engineering |
| genymotion | Android emulator |
| intel-sgx-sdk-bin | SGX development |

---

## Summary: Recommended Additions

### Immediate (Essential)

```nix
# Input Method
i18n.inputMethod = {
  enable = true;
  type = "fcitx5";
  fcitx5.addons = with pkgs; [
    fcitx5-mozc
    fcitx5-gtk
  ];
};

# Fonts
fonts.packages = with pkgs; [
  noto-fonts-cjk-sans
  noto-fonts-emoji
  ipaexfont
  nerd-fonts.source-code-pro
];
```

### High Priority Packages

```nix
# Development
pkgs.go
pkgs.rustup
pkgs.deno
pkgs.python3
pkgs.gh
pkgs.act
pkgs.mise
pkgs.gdb
pkgs.hyperfine

# Office
pkgs.libreoffice
pkgs.thunderbird

# Media
pkgs.audacity
pkgs.obs-studio
pkgs.inkscape
pkgs.ffmpeg
pkgs.yt-dlp

# Tools
pkgs.htop
pkgs.lsd
pkgs.tree
pkgs.unzip
pkgs.nmap
```

### Medium Priority

```nix
# Virtualization (NixOS modules)
virtualisation.libvirtd.enable = true;
programs.virt-manager.enable = true;
programs.steam.enable = true;

# Security
pkgs.ghidra
pkgs.wireshark
pkgs.binwalk
```

---

## Package Count Comparison

| Category | Arch Linux | NixOS XPS9350 |
|----------|------------|---------------|
| Total packages | 2,178 | ~50 |
| Desktop (GNOME) | ~30 | ~12 extensions |
| Development languages | ~10 | 0 (volta only) |
| CLI tools | ~50 | ~20 |
| GUI apps | ~30 | ~10 |
| Security tools | ~15 | 0 |
| Fonts | ~10 | 0 (system default) |

**Note**: Many Arch packages are dependencies. The actual "user-installed" difference is smaller but still significant.
