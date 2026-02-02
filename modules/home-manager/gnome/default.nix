# GNOME configuration for Home Manager
# Migrated from Arch Linux dconf settings
{ lib, pkgs, ... }:

with lib.hm.gvariant;

{
  dconf = {
    enable = true;
    settings = {
      # === GNOME Shell ===
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [ ];
        enabled-extensions = [
          "kimpanel@kde.org"
          "gsconnect@andyholmes.github.io"
          "arcmenu@arcmenu.com"
          "dash-to-panel@jderose9.github.com"
          "status-icons@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "pano@elhan.io"
          "ding@rastersoft.com"
        ];
        favorite-apps = [
          "brave-browser.desktop"
          "google-chrome.desktop"
          "org.gnome.Nautilus.desktop"
          "spotify-launcher.desktop"
          "org.gnome.Terminal.desktop"
          "virtualbox.desktop"
          "code.desktop"
          "vesktop.desktop"
          "slack.desktop"
          "mattermost-desktop.desktop"
          "GitKraken.desktop"
          "io.missioncenter.MissionCenter.desktop"
          "com.usebottles.bottles.desktop"
        ];
      };

      # === Desktop Interface ===
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        icon-theme = "Papirus-Dark";
        show-battery-percentage = true;
        toolkit-accessibility = false;
      };

      # === Window Manager Preferences ===
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      # === Mutter Settings ===
      "org/gnome/mutter" = {
        check-alive-timeout = mkUint32 60000;
        edge-tiling = true;
        overlay-key = "Super_L";
      };

      # === Input Sources ===
      "org/gnome/desktop/input-sources" = {
        sources = [ (mkTuple [ "xkb" "us" ]) ];
      };

      # === Touchpad ===
      "org/gnome/desktop/peripherals/touchpad" = {
        two-finger-scrolling-enabled = true;
      };

      # === Session Settings ===
      "org/gnome/desktop/session" = {
        idle-delay = mkUint32 0;
      };

      # === Power Settings ===
      "org/gnome/settings-daemon/plugins/power" = {
        idle-dim = false;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };

      # === Night Light ===
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-schedule-automatic = false;
      };

      # === Nautilus Preferences ===
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        show-image-thumbnails = "always";
      };

      "org/gnome/nautilus/compression" = {
        default-compression-format = "zip";
      };

      # === GNOME Text Editor ===
      "org/gnome/TextEditor" = {
        restore-session = false;
      };

      # === GNOME Terminal ===
      "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        audible-bell = false;
        scrollback-unlimited = true;
      };

      # === Shell Keybindings ===
      "org/gnome/shell/keybindings" = {
        toggle-message-tray = [ ];
      };

      # === dconf-editor ===
      "ca/desrt/dconf-editor" = {
        show-warning = false;
      };

      # === GTK File Chooser Settings ===
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
        sort-directories-first = false;
        view-type = "list";
      };

      "org/gtk/settings/file-chooser" = {
        show-hidden = true;
        show-size-column = true;
        show-type-column = true;
        sort-directories-first = false;
      };

      # === Extension: ArcMenu ===
      "org/gnome/shell/extensions/arcmenu" = {
        enable-horizontal-flip = false;
        menu-height = 700;
        menu-layout = "Whisker";
        multi-monitor = true;
        search-entry-border-radius = mkTuple [ true 25 ];
        searchbar-default-top-location = "Bottom";
      };

      # === Extension: Dash to Panel ===
      "org/gnome/shell/extensions/dash-to-panel" = {
        animate-appicon-hover-animation-extent = {
          RIPPLE = 4;
          PLANK = 4;
          SIMPLE = 1;
        };
        dot-position = "BOTTOM";
        hotkeys-overlay-combo = "TEMPORARILY";
        isolate-monitors = true;
        panel-anchors = ''{"SHP-0x00000000":"MIDDLE","DEL-7TCP98AT08JS":"MIDDLE"}'';
        panel-element-positions = ''{"SHP-0x00000000":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"DEL-7TCP98AT08JS":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'';
        panel-lengths = ''{}'';
        panel-positions = ''{}'';
        panel-sizes = ''{}'';
        window-preview-title-position = "TOP";
      };

      # === Extension: Desktop Icons NG (DING) ===
      "org/gnome/shell/extensions/ding" = {
        add-volumes-opposite = false;
        check-x11wayland = true;
        show-home = false;
        show-volumes = false;
      };

      # === Extension: GSConnect ===
      "org/gnome/shell/extensions/gsconnect" = {
        devices = [ ];
        missing-openssl = false;
      };

      # === Extension: Pano (Clipboard Manager) ===
      "org/gnome/shell/extensions/pano" = {
        global-shortcut = [ "<Super>v" ];
        paste-on-select = false;
        play-audio-on-copy = false;
        send-notification-on-copy = false;
      };
    };
  };
}
