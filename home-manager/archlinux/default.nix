# Home Manager configuration for standalone Arch Linux
{ outputs, lib, ... }:
{
  imports = [
    # Centralized nixpkgs configuration
    outputs.modules.common.nixpkgs
  ]
  ++ (with outputs.modules.home-manager; [
    git
    gh
    zsh
    fish
    direnv
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

  qt.enable = lib.mkForce false;

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
    sessionVariables = {
      # No qt6ct here: it forces a light palette onto Kirigami apps (black-on-black fields)
      QT_STYLE_OVERRIDE = "kvantum";
    };
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
