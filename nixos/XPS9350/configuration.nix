# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  pkgs,
  outputs,
  inputs,
  hostname,
  ...
}:

{
  imports = [
    # System-level modules
    outputs.modules.nixos.system.zsh
    outputs.modules.nixos.system.network
    outputs.modules.nixos.system.locale
    outputs.modules.nixos.system.nixpkgs
    outputs.modules.nixos.system.common
    outputs.modules.nixos.system.boot
    outputs.modules.nixos.system.fonts
    outputs.modules.nixos.system.logind
    outputs.modules.nixos.system.virtualization
    outputs.modules.nixos.system.tuned
    outputs.modules.nixos.system.nix-ld
    outputs.modules.nixos.system.audio
    outputs.modules.nixos.system.printing

    # User-level modules
    outputs.modules.nixos.user.gnome
    outputs.modules.nixos.user.hyprland
    outputs.modules.nixos.user.fcitx5
    outputs.modules.nixos.user.steam
    outputs.modules.nixos.user.archtools
    outputs.modules.nixos.user.apps

    # nm-vpngate - VPN Gate client for NetworkManager
    inputs.nm-vpngate.nixosModules.default

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Home Manager NixOS Module
    inputs.home-manager.nixosModules.home-manager

    # Minegrub theme for GRUB bootloader
    inputs.minegrub-theme.nixosModules.default

    # IPU7 camera support modules (from PR #479283)
    ./ipu7-libcamera.nix # Base support + libcamera backend (working)
    ./ipu7-icamerasrc.nix # icamerasrc/v4l2-relayd backend (requires out-of-tree driver)
  ];

  # Boot loader type (grub or systemd-boot)
  boot.loader.type = "grub";

  # Arch keeps these filenames stable across kernel updates, so the entries stay
  # valid without rebuilding NixOS every time Arch ships a new kernel.
  # NixOS adds two entries of its own; keep minegrubEntryCount at 2 + these.
  boot.loader.minegrubEntryCount = 5;
  boot.loader.grub.extraEntries = ''
    menuentry "Arch Linux (linux-myxps)" --class arch --class gnu-linux --class os {
      search --no-floppy --fs-uuid --set=root 1555-49E0
      linux /vmlinuz-linux-myxps root=UUID=889a598f-9c2d-4c07-be12-e3afcb7fbde2 rw loglevel=3 quiet splash
      initrd /initramfs-linux-myxps.img
    }

    menuentry "Arch Linux (linux-zen)" --class arch --class gnu-linux --class os {
      search --no-floppy --fs-uuid --set=root 1555-49E0
      linux /vmlinuz-linux-zen root=UUID=889a598f-9c2d-4c07-be12-e3afcb7fbde2 rw loglevel=3 quiet splash
      initrd /initramfs-linux-zen.img
    }

    menuentry "Windows 11" --class windows --class os {
      insmod part_gpt
      insmod fat
      insmod chain
      search --no-floppy --fs-uuid --set=root 2A16-4E48
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

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

  # Enable audio with PipeWire
  audio.enable = true;

  # Enable user GUI applications
  user.apps = {
    enable = true;
    gaming = true; # Include Bottles for Wine
  };

  networking.hostName = hostname; # Change dirname to change hostname :P
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.hayao = {
    isNormalUser = true;
    description = "Hayao";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "vboxusers"
      "video"
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # Import your home-manager configuration
      hayao = import ../../home-manager/linux;
    };
  };

  # Use kernel 6.18 instead of latest (6.19+) due to VirtualBox incompatibility
  # VirtualBox vboxdrv module fails to build on 6.19+ (nixpkgs issue #491434)
  # TODO: Switch back to linuxPackages_latest when VirtualBox is fixed
  boot.kernelPackages = pkgs.unstable.linuxPackages_6_18;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
