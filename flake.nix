{
  description = "Hayao Nix Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # IPU7 camera support (PR #479283) - remove once merged into nixpkgs
    nixpkgs-ipu7.url = "github:NixOS/nixpkgs/pull/479283/head";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
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
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;
      # このFlakesでサポートするシステム
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # systems をループして各システム用の attribute を生成する関数
      forAllSystems =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
    in
    {
      # Formatter for your nix files, available through 'nix fmt'
      formatter = forAllSystems (system: (import inputs.nixpkgs { inherit system; }).nixfmt-rfc-style);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # modules
      modules = import ./modules; # { inherit inputs; };

      # nix os
      nixosConfigurations = import ./nixos { inherit inputs outputs; };

      # nix-darwin
      darwinConfigurations = import ./darwin { inherit inputs outputs; };

      # home-manager
      homeConfigurations = import ./home-manager { inherit inputs outputs; };

      # nix-on-droid
      nixOnDroidConfigurations = import ./nix-on-droid { inherit inputs outputs; };

      # Task runner applications
      apps = import ./tasks.nix { inherit inputs systems; };
    };
}
