{ ... }: {
  # Nixpkgs
  nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

  # You can access packages and modules from different nixpkgs revs
  # at the same time. Here's an working example:
  nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.



  # Nix-darwin for macOS systems management
  nix-darwin = {
    url = "github:LnL7/nix-darwin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Home manager
  home-manager.url = "github:nix-community/home-manager/release-24.11";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
}

