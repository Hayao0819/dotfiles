{
  outputs,
  ...
}:
{
  imports = [
    outputs.modules.home.git
    outputs.modules.home.zsh
    # outputs.modules.home.pkgs

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
  ];

  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
