# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  ...
}:
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

  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  # Enable audio with PipeWire and EasyEffects
  audio.enable = true;

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
