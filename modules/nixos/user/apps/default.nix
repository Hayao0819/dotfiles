# User GUI applications module
# Provides optional package sets that can be enabled per-user
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.apps;
in
{
  options.user.apps = {
    enable = lib.mkEnableOption "User GUI applications";

    browsers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install web browsers (Firefox, Brave, Chrome)";
    };

    communication = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install communication apps (Discord, Slack, Zoom)";
    };

    media = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install media apps (VLC, Spotify)";
    };

    development = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install development tools (VS Code, GitKraken)";
    };

    gaming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install gaming tools (Bottles)";
    };

    utilities = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install system utilities (GParted, Baobab, Mission Center)";
    };

    office = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install office suite (OnlyOffice)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      lib.optionals cfg.browsers (
        with pkgs;
        [
          firefox-bin
          brave
          google-chrome
        ]
      )
      ++ lib.optionals cfg.communication (
        with pkgs;
        [
          vesktop # Discord client with Vencord built-in
          slack
          zoom-us
        ]
      )
      ++ lib.optionals cfg.media (
        with pkgs;
        [
          vlc
          spotify
        ]
      )
      ++ lib.optionals cfg.development [
        pkgs.gitkraken
        pkgs.unstable.vscode-fhs # VS Code with FHS environment for extension compatibility
      ]
      ++ lib.optionals cfg.gaming (
        with pkgs;
        [
          bottles # Wine prefix manager
          azahar # Nintendo 3DS emulator (Citra-based)
        ]
      )
      ++ lib.optionals cfg.utilities (
        with pkgs;
        [
          mission-center # System monitor like Windows Task Manager
          gparted
          baobab # GNOME disk usage analyzer
          # @orzklv: error: 'globalprotect-openconnect' was removed because it was unmaintained in Nixpkgs and needed upgrading to the Tauri rewrite, as the old version depends on the removed Qt 5 WebEngine
          # globalprotect-openconnect # GlobalProtect VPN client with GUI
        ]
      )
      ++ lib.optionals cfg.office (
        with pkgs;
        [
          onlyoffice-desktopeditors # Office suite for documents, spreadsheets, presentations
        ]
      );
  };
}
