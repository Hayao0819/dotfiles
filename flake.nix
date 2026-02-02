{
  description = "Hayao Nix Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      nix-darwin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # このFlakesでサポートするシステム
      # systems = [
      #   # Not recommened
      #   # "i686-linux"

      #   "aarch64-linux"
      #   "x86_64-linux"

      #   "aarch64-darwin"
      #   "x86_64-darwin"
      # ];

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      # forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      # packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'nixpkgs-fmt' include 'alejandra'
      # formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      formatter.x86_64-linux =
        (import inputs.nixpkgs {
          system = "x86_64-linux";
        }).nixfmt-rfc-style;

      # Development environment
      # Accessible through 'nix develop' or 'nix develop -c $SHELL' if you're zsh user
      # devShells = forAllSystems
      #   (system: {
      #     default = import ./shell.nix
      #       {
      #         pkgs = nixpkgs.legacyPackages.${system};
      #       };
      #   });

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # modules
      modules = import ./modules; # { inherit inputs; };

      # nix os
      nixosConfigurations = import ./nixos {
        inherit
          inputs
          outputs
          nixpkgs
          nixpkgs-unstable
          ;
      };

      # nix-darwin
      darwinConfigurations = import ./darwin { inherit inputs outputs nix-darwin; };

      # home-manager
      homeConfigurations = import ./home { inherit inputs outputs; };
    };
}
