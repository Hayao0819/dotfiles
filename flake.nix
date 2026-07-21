{
  description = "Hayao Nix Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # IPU7 camera support (PR #479283) - remove once merged into nixpkgs
    nixpkgs-ipu7.url = "github:NixOS/nixpkgs/pull/479283/head";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Better flake management
    flake-parts.url = "github:hercules-ci/flake-parts";

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
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      let
        outputs = self;
      in
      {
        imports = [ ];
        flake = {
          overlays = import ./overlays { inherit inputs; };
          modules = import ./modules { inherit inputs; };
          nixosConfigurations = import ./nixos { inherit inputs outputs; };
          darwinConfigurations = import ./darwin { inherit inputs outputs; };
          homeConfigurations = import ./home-manager { inherit inputs outputs; };
          nixOnDroidConfigurations = import ./nix-on-droid { inherit inputs outputs; };
        };
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            pkgs,
            system,
            ...
          }:
          {
            formatter = pkgs.nixfmt-rs;

            packages = import ./pkgs { inherit pkgs; };

            apps = import ./tasks.nix { inherit inputs system pkgs; };

            devShells.default = import ./shell.nix { inherit pkgs; };
          };
      }
    );
}
