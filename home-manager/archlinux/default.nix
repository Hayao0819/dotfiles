{
  outputs,
  ...
}:
{
  imports = [
    outputs.modules.home-manager.nixpkgs
    outputs.modules.home-manager.git
    outputs.modules.home-manager.zsh
    outputs.modules.home-manager.pkgs

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
