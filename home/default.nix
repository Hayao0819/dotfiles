{ inputs, outputs, ... }: {
  # Stable Home Manager for Non NixOS
  "hayao@stable" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
    extraSpecialArgs = { inherit inputs outputs; };
    modules = [
      # > Our main home-manager configuration file <
      ./linux
    ];
  };

  # Unstable latest rolling Home Manager for Non NixOS
  # "hayao@unstable" = inputs.home-manager.lib.homeManagerConfiguration {
  #   pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
  #   extraSpecialArgs = { inherit inputs outputs; };
  #   modules = [
  #     # > Our main home-manager configuration file <
  #     ./home/linux.nix
  #   ];
  # };

  # Stabel darwin Home Manager
  # "hayao@darwin-stable" = home-manager.lib.homeManagerConfiguration {
  #   pkgs = nixpkgs.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
  #   extraSpecialArgs = { inherit inputs outputs; };
  #   modules = [
  #     # > Our main home-manager configuration file <
  #     ./home/darwin.nix
  #   ];
  # };

  # # Unstabel darwin Home Manager
  # "hayao@darwin-unstable" = home-manager.lib.homeManagerConfiguration {
  #   pkgs = nixpkgs-unstable.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
  #   extraSpecialArgs = { inherit inputs outputs; };
  #   modules = [
  #     # > Our main home-manager configuration file <
  #     ./home/darwin.nix
  #   ];
  # };

  # Alias to darwin-unstable for Personal MacBook for autodetection
  # "hayao@MacBookProM1" = self.homeConfigurations."hayao@darwin-stable"; # MacBook Pro M1
}
