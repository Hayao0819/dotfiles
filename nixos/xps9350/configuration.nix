# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  outputs,
  inputs,
  ...
}:

{
  imports = [
    # You can import other NixOS modules here
    outputs.modules.nixos.zsh
    outputs.modules.nixos.network
    outputs.modules.nixos.locale
    outputs.modules.nixos.gnome
    outputs.modules.nixos.nixpkgs
    outputs.modules.nixos.common
    #outputs.modules.nixos.systemd-boot
    outputs.modules.nixos.grub
    outputs.modules.nixos.docker
    outputs.modules.nixos.fonts
    outputs.modules.nixos.virtualization
    outputs.modules.nixos.archfornixos
    outputs.modules.nixos.steam
    outputs.modules.nixos.tuned
    outputs.modules.nixos.nix-ld

    # nm-vpngate - VPN Gate client for NetworkManager
    inputs.nm-vpngate.nixosModules.default

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Home Manager NixOS Module
    inputs.home-manager.nixosModules.home-manager

    # IPU7 camera support module (from PR #479283)
    ./ipu7.nix
  ];

  # Intel IPU7 (Lunar Lake) camera support
  # Platform options: "ipu7x" or "ipu75xa" - check your hardware
  hardware.ipu7 = {
    enable = true;
    platform = "ipu7x"; # Lunar Lake default
  };

  # VPN Gate client for NetworkManager
  services.nm-vpngate = {
    enable = true;
    autoConnect = false; # Manual connection only
  };

  networking.hostName = "XPS9350"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hayao = {
    isNormalUser = true;
    description = "Hayao";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "vboxusers"
    ];
    packages = with pkgs; [
      # Add GUI apps only here
      firefox-bin
      vesktop # Discord client with Vencord built-in

      # Browsers
      brave
      google-chrome

      # Communication
      slack

      # Media
      vlc
      spotify

      # Development
      gitkraken
      vscode-fhs # VS Code with FHS environment for extension compatibility

      # System tools
      mission-center # System monitor like Windows Task Manager

      # Gaming/Wine
      bottles # Wine prefix manager

      # Video conferencing
      zoom-us

      # Disk utilities
      gparted
      baobab # GNOME disk usage analyzer

      # VPN
      globalprotect-openconnect # GlobalProtect VPN client with GUI
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # Import your home-manager configuration
      hayao = import ../../home-manager/linux;
    };
  };

  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
