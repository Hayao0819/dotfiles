# Arch Linux tools for NixOS
# Provides pacman and arch-install-scripts for managing/installing Arch Linux systems
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Arch Linux package manager
    pacman

    # Arch Linux installation scripts
    # Includes: pacstrap, genfstab, arch-chroot, etc.
    arch-install-scripts
  ];
}
