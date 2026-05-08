---
description: Apply current dconf settings to NixOS Home Manager configuration
allowed-tools: Bash(dconf dump:*), Bash(gnome-shell --version:*), Read, Edit, Glob, Grep, WebSearch, WebFetch(domain:extensions.gnome.org)
---

# Apply dconf Settings to Home Manager

Synchronize current GNOME dconf settings to the declarative Nix configuration.

## Step 1: Dump Current dconf Settings

```bash
dconf dump /
```

## Step 2: Read Existing Configuration

Read the current dconf-generated.nix file:

- Path: `modules/home-manager/gnome/dconf-generated.nix`

## Step 3: Compare and Identify Changes

Compare the current dconf dump with the existing configuration. Focus on:

### Settings to Include (Machine-Independent)

Include these categories:

1. **GNOME Shell**
   - `org/gnome/shell` - enabled-extensions, favorite-apps, disabled-extensions
   - `org/gnome/shell/keybindings` - keyboard shortcuts

2. **Desktop Appearance**
   - `org/gnome/desktop/interface` - color-scheme, icon-theme, show-battery-percentage
   - `org/gnome/desktop/wm/preferences` - button-layout

3. **Desktop Behavior**
   - `org/gnome/mutter` - edge-tiling, overlay-key, check-alive-timeout
   - `org/gnome/desktop/input-sources` - sources, xkb-options
   - `org/gnome/desktop/peripherals/touchpad` - scrolling settings
   - `org/gnome/desktop/session` - idle-delay

4. **Power Management**
   - `org/gnome/settings-daemon/plugins/power` - sleep settings, idle-dim
   - `org/gnome/settings-daemon/plugins/color` - night-light settings

5. **Application Settings**
   - `org/gnome/Console` - font settings
   - `org/gnome/nautilus/*` - file manager preferences
   - `org/gnome/TextEditor` - editor settings
   - `org/gnome/terminal/legacy/profiles:/:*` - terminal settings

6. **GTK Settings**
   - `org/gtk/gtk4/settings/file-chooser` - file chooser preferences
   - `org/gtk/settings/file-chooser` - GTK3 file chooser

7. **Extension Settings**
   - `org/gnome/shell/extensions/*` - all extension configurations

8. **Miscellaneous**
   - `ca/desrt/dconf-editor` - dconf-editor settings

### Settings to EXCLUDE (Machine-Dependent or Transient)

Do NOT include:

1. **Window State/Size** - `last-window-size`, `window-size`, `initial-size`, `is-maximized`
2. **Notification History** - `org/gnome/desktop/notifications/application/*`
3. **Recent Files/Folders** - `last-folder-path`, `recently-installed-apps`
4. **Version/Migration Markers** - `welcome-dialog-last-shown-version`, `migrated*`
5. **Portal/Filechooser State** - `org/gnome/portal/filechooser/*`
6. **Housekeeping Timestamps** - `donation-reminder-last-shown`
7. **Extension Version Markers** - `extension-version`, `update-notifier-project-version`
8. **Network-Specific Settings** - `org/gnome/nm-applet/eap/*`
9. **App Folders** - `org/gnome/desktop/app-folders/*` (typically auto-generated)
10. **Control Center State** - `org/gnome/control-center/last-panel`
11. **Calendar State** - `org/gnome/calendar/active-view`

## Step 4: Check for Obsolete Extensions/Settings

For each extension in `enabled-extensions`, verify it's still valid:

1. Get current GNOME version:

   ```bash
   gnome-shell --version
   ```

2. Search GNOME Extensions website to check if each extension is:
   - Still maintained
   - Compatible with current GNOME version
   - Not archived or deprecated

3. If an extension is obsolete:
   - Remove from `enabled-extensions`
   - Remove its settings section
   - Note any successor/replacement extension

4. Check if extensions in the Nix config (`modules/nixos/gnome/default.nix`) match:
   - Verify packages exist for all enabled extensions
   - Identify any extensions that are commented out or removed

## Step 5: Update dconf-generated.nix

Update the file with changes:

1. Add new settings that are machine-independent
2. Update changed values
3. Remove obsolete extension settings
4. Keep the existing structure and comments

### Nix Syntax Reference

```nix
# Strings
key = "value";

# Booleans
key = true;
key = false;

# Lists
key = [ "item1" "item2" ];

# Empty list
key = [ ];

# Uint32 (use helper)
key = mkUint32 60000;

# Tuple (use helper)
sources = [ (mkTuple [ "xkb" "us" ]) ];

# JSON as string (escape with '')
key = ''{"json": "value"}'';
```

## Step 6: Validate

```bash
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
```

## Summary Output

After completion, provide:

1. List of added settings
2. List of updated settings
3. List of removed obsolete settings
4. Any warnings about deprecated extensions
