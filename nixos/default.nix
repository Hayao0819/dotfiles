{ nixpkgs, inputs, outputs, ... }: {
  XPS9350 = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs outputs; };
    modules = [
      # > Our main nixos configuration file <
      ./xps9350/configuration.nix
    ];
  };

  Installer = nixpkgs.lib.nixosSystem {
    modules = [
      ({ pkgs, lib, modulesPath, ... }:
        {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix")
          ];

          boot.supportedFilesystems.zfs = lib.mkForce false;
          boot.kernelPackages = pkgs.linuxPackages_latest;

          nixpkgs = {
            hostPlatform = "x86_64-linux";
            config = {
              # Disable if you don't want unfree packages
              allowUnfree = true;
              allowUnsupportedSystem = true;
            };
          };

          nix.settings = {
            # Enable flakes and new 'nix' command
            experimental-features = "nix-command flakes";
          };
        })
    ];
  };
}
