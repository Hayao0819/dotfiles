{
  outputs,
  ...
}:
{
  imports = [
    # Note: nixpkgs, git, zsh, fish, pkgs modules are imported via ../linux
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
  ];

  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };


  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
