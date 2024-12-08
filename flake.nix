{
  description = "Your new nix config";

  inputs = import ./upstream.nix;

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nixpkgs-unstable
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # このFlakesでサポートするシステム
      systems = [
        # Not recommened
        # "i686-linux"

        "aarch64-linux"
        "x86_64-linux"

        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'nixpkgs-fmt' include 'alejandra'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      # Development environment
      # Accessible through 'nix develop' or 'nix develop -c $SHELL' if you're zsh user
      devShells = forAllSystems
        (system: {
          default = import ./shell.nix
            {
              pkgs = nixpkgs.legacyPackages.${system};
            };
        });

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # My nix modules
      modules = import ./modules; #{ inherit inputs; };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = import ./nixos { inherit inputs outputs nixpkgs; };

      # Darwin configuration entrypoint
      # Available through 'darwin-rebuild build --flake .#your-hostname'
      # Stored at/as root/darwin/<alias name for machine>/*.nix
      darwinConfigurations = self.lib.config.attrSystem {
        inherit inputs outputs;
        type = "darwin";
        list = [
          {
            name = "Sokhibjons-MacBook-Pro";
            alias = "macbook-pro";
          }
          {
            name = "Sokhibjons-Mac-Studio";
            alias = "mac-studio";
          }
        ];
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = ./home; # { inherit inputs outputs; };
    };
}
