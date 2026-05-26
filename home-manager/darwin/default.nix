# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  ...
}:
{
  imports = [
    # Centralized nixpkgs configuration
    outputs.modules.common.nixpkgs

    # Import modules from this flake
    outputs.modules.home-manager.git
    outputs.modules.home-manager.gh
    outputs.modules.home-manager.zsh
    outputs.modules.home-manager.direnv
    outputs.modules.home-manager.pkgs
    outputs.modules.home-manager.llm
  ];

  home = {
    username = "hayao";
    homeDirectory = "/Users/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
