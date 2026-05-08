# Home Manager configuration for Debian
{ outputs, ... }:
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
    pkgs
    wallpapers
    llm
    audio
  ]);

  # EasyEffects presets only (package is managed by apt)
  audio.easyeffects.presets.enable = true;

  # User configuration
  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Use systemd to manage Home Manager services
  systemd.user.startServices = "sd-switch";

  # State version - don't change this after initial setup
  home.stateVersion = "24.11";
}
