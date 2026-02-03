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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
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
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
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
      homeConfigurations = import ./home-manager { inherit inputs outputs; };

      # Task runner applications
      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Copy scripts to a derivation so they can find each other
          scriptsDir = pkgs.stdenvNoCC.mkDerivation {
            name = "dotfiles-scripts";
            src = ./scripts;
            installPhase = ''
              mkdir -p $out
              cp -r $src/* $out/
              chmod +x $out/*.sh
            '';
          };

          # Create a wrapper that provides necessary tools
          taskRunner = pkgs.writeShellScript "dotfiles-task-runner" ''
            #!/usr/bin/env bash
            export PATH="${pkgs.jq}/bin:${pkgs.git}/bin:${home-manager.packages.${system}.default}/bin:$PATH"
            exec ${pkgs.bash}/bin/bash ${scriptsDir}/task-runner.sh "$@"
          '';

        in {
          # Default app - the main task runner
          default = {
            type = "app";
            program = toString taskRunner;
          };

          # Alias for deployment
          deploy = {
            type = "app";
            program = toString taskRunner;
          };

          # Quick access apps for specific tasks
          update = {
            type = "app";
            program = toString (pkgs.writeShellScript "update" ''
              ${taskRunner} update
            '');
          };

          check = {
            type = "app";
            program = toString (pkgs.writeShellScript "check" ''
              ${taskRunner} check
            '');
          };

          clean = {
            type = "app";
            program = toString (pkgs.writeShellScript "clean" ''
              ${taskRunner} clean
            '');
          };

          status = {
            type = "app";
            program = toString (pkgs.writeShellScript "status" ''
              ${taskRunner} status
            '');
          };
        }
      );
    };
}
