# Home Manager configuration for standalone Arch Linux
{ outputs, lib, ... }:
{
  imports = [
    # Centralized nixpkgs configuration
    ../../modules/common/nixpkgs.nix
  ]
  ++ (with outputs.modules.home-manager; [
    git
    gh
    zsh
    fish
    pkgs
    gnome
    wallpapers
    llm
    xdg
    theme
    audio
  ]);

  # EasyEffects presets only (package is managed by pacman)
  audio.easyeffects.presets.enable = true;

  # On Arch, Qt theming packages (kvantum, qt6ct, qt5ct) are installed via pacman.
  # Disable Home Manager's qt module to prevent Nix's QT_PLUGIN_PATH injection,
  # which causes duplicate style plugin loading and infinite recursion in QProxyStyle.
  qt.enable = lib.mkForce false;
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
  };

  # Alias .desktop files to match NixOS naming for dconf favorite-apps consistency
  xdg.desktopEntries = {
    gitkraken = {
      name = "GitKraken";
      exec = "gitkraken %f";
      icon = "gitkraken";
      terminal = false;
      categories = [
        "Development"
        "RevisionControl"
      ];
      settings = {
        NoDisplay = "true";
        StartupWMClass = "gitkraken";
      };
    };
    spotify = {
      name = "Spotify";
      exec = "spotify-launcher %U";
      icon = "spotify-launcher";
      terminal = false;
      categories = [
        "Audio"
        "Music"
        "Player"
        "AudioVideo"
      ];
      mimeType = [ "x-scheme-handler/spotify" ];
      settings = {
        NoDisplay = "true";
        StartupWMClass = "spotify";
      };
    };
  };

  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
