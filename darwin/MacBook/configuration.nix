{ inputs, ... }:
{
  imports = [
    # Home Manager Darwin Module
    inputs.home-manager.darwinModules.home-manager
  ];

  # Networking DNS & Interfaces
  networking = {
    computerName = "Hayao's MacBook Pro";
    localHostName = "Hayao-MacBook";
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
