---
name: apply-dconf
description: Synchronizes current GNOME dconf settings to declarative Nix Home Manager configuration. Dumps dconf, compares with existing config, and updates dconf-generated.nix.
when_to_use: When the user asks to sync, apply, or update dconf/GNOME settings to their Nix configuration.
allowed-tools: Bash(dconf dump:*), Bash(gnome-shell --version:*), Read, Edit, Glob, Grep, WebSearch, WebFetch(domain:extensions.gnome.org)
---

# Apply dconf Settings to Home Manager

## 1. Dump Current Settings

```bash
dconf dump /
```

## 2. Read Existing Config

Read `modules/home-manager/gnome/dconf-generated.nix`.

## 3. Compare and Update

### Include (machine-independent)

- `org/gnome/shell` — extensions, favorites, keybindings
- `org/gnome/desktop/interface` — color-scheme, icon-theme, battery
- `org/gnome/desktop/wm/preferences` — button-layout
- `org/gnome/mutter` — edge-tiling, overlay-key
- `org/gnome/desktop/input-sources` — keyboard layouts
- `org/gnome/desktop/peripherals/touchpad` — scrolling
- `org/gnome/settings-daemon/plugins/power` — sleep, idle-dim
- `org/gnome/settings-daemon/plugins/color` — night-light
- `org/gnome/shell/extensions/*` — all extension configs
- Application settings (Console, nautilus, TextEditor, terminal)

### Exclude (transient/machine-dependent)

Window state, notification history, recent files, version markers, portal state, housekeeping timestamps, network-specific, app-folders, control-center state.

## 4. Verify Extensions

For each extension in `enabled-extensions`:
1. Check GNOME version: `gnome-shell --version`
2. Verify compatibility on extensions.gnome.org
3. Remove obsolete extensions and their settings

## 5. Validate

```bash
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
```

Report: added, updated, removed settings, and extension warnings.
