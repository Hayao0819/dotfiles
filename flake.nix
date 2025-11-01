{
  description = "Your new nix config";

  inputs = {
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

    # Disko for easier partition management
    # disko = {
    #   url = "github:nix-community/disko";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nixpkgs-unstable
    , nix-darwin
    , disko
    , ...
    } @ inputs:
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
      # formatter.x86_64-linux = import inputs.nixpkgs {
      #   system = "x86_64-linux";
      # }.nixfmt;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

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
      # overlays = import ./overlays { inherit inputs; };

      # My nix modules
      modules = import ./modules; #{ inherit inputs; };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      # nixosConfigurations = import ./nixos { inherit inputs outputs nixpkgs nixpkgs-unstable; };

      # Darwin configuration entrypoint
      # Available through 'darwin-rebuild build --flake .#your-hostname'
      # Stored at/as root/darwin/<alias name for machine>/*.nix
      # darwinConfigurations = import ./darwin { inherit inputs outputs nix-darwin; };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = import ./home { inherit inputs outputs; };
    };
}
