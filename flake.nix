{
  description = "Hayao Nix Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # IPU7 camera support (PR #479283) - remove once merged into nixpkgs
    nixpkgs-ipu7.url = "github:NixOS/nixpkgs/pull/479283/head";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    nm-vpngate.url = "github:Hayao0819/nm-vpngate";

    minegrub-theme.url = "github:Lxtharia/minegrub-theme";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Better flake management
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      let
        # Self reference
        outputs = self;
      in
      {
        imports = [
          # Optional: use external flake logic, e.g.
          # inputs.foo.flakeModules.default

          # Read more here:
          # https://flake.parts/best-practices-for-module-writing.html
        ];
        flake = {
          # Put your original flake attributes here.

          # Your custom packages and modifications, exported as overlays
          overlays = import ./overlays { inherit inputs; };

          # modules
          modules = import ./modules { inherit inputs; };

          # nix os
          nixosConfigurations = import ./nixos { inherit inputs outputs; };

          # nix-darwin
          darwinConfigurations = import ./darwin { inherit inputs outputs; };

          # home-manager
          homeConfigurations = import ./home-manager { inherit inputs outputs; };

          # nix-on-droid
          nixOnDroidConfigurations = import ./nix-on-droid { inherit inputs outputs; };
        };
        systems = [
          # systems for which you want to build the `perSystem` attributes
          "x86_64-linux"
          # ...
        ];
        perSystem =
          {
            config,
            pkgs,
            system,
            ...
          }:
          {
            # Formatter for your nix files, available through 'nix fmt'
            formatter = pkgs.nixfmt-tree;

            # Packages
            packages = import ./pkgs {
              inherit pkgs;
              flake = self;
            };

            # Task runner applications
            apps = import ./tasks.nix { inherit inputs system pkgs; };

            # Development environment
            devShells.default = import ./shell.nix { inherit pkgs; };
          };
      }
    );
}
