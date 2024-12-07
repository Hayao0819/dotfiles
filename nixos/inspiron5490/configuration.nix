# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, outputs, inputs, ... }:

{
  imports =
    [
      # You can import other NixOS modules here
      outputs.nixosModules.zsh
      outputs.nixosModules.network
      outputs.nixosModules.locale
      outputs.nixosModules.gnome
      outputs.nixosModules.common

      # Or modules from other flakes (such as nixos-hardware):
      # inputs.hardware.nixosModules.common-cpu-amd
      # inputs.hardware.nixosModules.common-ssd

      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Home Manager NixOS Module
      inputs.home-manager.nixosModules.home-manager
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Inspiron5490"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hayao = {
    isNormalUser = true;
    description = "Hayao";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Add GUI apps only here
      # Add CLI apps at modules/home-manager/pkgs/*
      # e.g: discord, telegram-desktop, spotify, firefox
      firefox-bin
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # Import your home-manager configuration
      hayao = import ../../home/linux.nix;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # > Tip: Don't use unless your machine has multiple user
  # > Instead, use modules/home-manager/pkgs to define pkgs
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
