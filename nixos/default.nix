{ nixpkgs, inputs, outputs, ... }: {
  # Inspiron 5450
  Inspiron5490 = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs outputs; };
    modules = [
      # > Our main nixos configuration file <
      ./nixos/inspiron5490/configuration.nix
    ];
  };
  Installer = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ pkgs, modulesPath, ... }:
        {
          imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix") ];

          boot.supportedFilesystems = [ "zfs" ];
          boot.kernelPackages = pkgs.linuxPackages_6_11;
        })
    ];
  };
}
