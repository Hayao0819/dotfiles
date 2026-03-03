# nix-on-droid configuration for Termux (Android)
{ outputs, pkgs, ... }:
{
  system.stateVersion = "24.05";

  # Login shell
  user.shell = "${pkgs.fish}/bin/fish";

  # System-level packages
  environment.packages = with pkgs; [
    git
    vim
    openssh
  ];

  # Home Manager integration
  home-manager.config =
    { ... }:
    {
      imports = with outputs.modules.home-manager; [
        git
        gh
        zsh
        fish
        pkgs
        llm
        xdg
      ];

      packages.isHeadless = true;

      home.stateVersion = "24.11";
    };
}
