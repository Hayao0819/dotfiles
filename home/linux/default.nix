# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
