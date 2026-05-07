{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    # Import common nixpkgs configuration
    ../../modules/common/nixpkgs.nix

    # Graphical installer configurations
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix")
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.hostPlatform = "x86_64-linux";

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes pipe-operators";
  };
}
