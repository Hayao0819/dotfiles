# Home Manager configuration for standalone Arch Linux
{ outputs, ... }:
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
  ]);

  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
