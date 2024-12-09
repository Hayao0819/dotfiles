{ nixpkgs, inputs, outputs, ... }: {
  # Inspiron 5450
  Inspiron5490 = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs outputs; };
    modules = [
      # > Our main nixos configuration file <
      ./inspiron5490/configuration.nix
    ];
  };

  XPS9350 = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs outputs; };
    modules = [
      # > Our main nixos configuration file <
      ./xps9350/configuration.nix
    ];
  };

  Installer = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ pkgs, lib, modulesPath, ... }:
        {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix")
          ];

          boot.supportedFilesystems.zfs = lib.mkForce false;
          boot.kernelPackages = pkgs.linuxPackages_latest;

        })
    ];
  };
}
