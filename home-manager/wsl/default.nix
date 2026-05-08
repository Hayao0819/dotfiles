# Home Manager configuration for WSL
# Reuses common modules, excludes GUI-specific ones (gnome, wallpapers, audio, theme)
{
  outputs,
  ...
}:
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
    llm
    xdg
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
