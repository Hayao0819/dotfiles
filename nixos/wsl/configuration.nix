# NixOS-WSL configuration
{
  pkgs,
  outputs,
  inputs,
  ...
}:

{
  imports = [
    # NixOS-WSL module
    inputs.nixos-wsl.nixosModules.wsl

    # System-level modules (reused from existing configuration)
    outputs.modules.nixos.system.zsh
    outputs.modules.nixos.system.locale
    outputs.modules.nixos.system.nixpkgs
    outputs.modules.nixos.system.common
    outputs.modules.nixos.system.nix-ld

    # Home Manager NixOS Module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Set the host platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # WSL-specific settings
  wsl = {
    enable = true;
    defaultUser = "hayao";

    # Docker Desktop integration (uses Windows Docker Desktop)
    docker-desktop.enable = true;

    # Windows Start Menu launchers for GUI apps
    startMenuLaunchers = true;

    # WSL configuration (/etc/wsl.conf)
    wslConf = {
      # Windows PATH integration
      interop.appendWindowsPath = true;

      # Automount settings
      automount = {
        enabled = true;
        mountFsTab = true;
      };

      # Network settings (managed by WSL)
      network.generateHosts = true;
    };
  };

  networking.hostName = "NixOS-WSL";

  # Define a user account
  users.users.hayao = {
    isNormalUser = true;
    description = "Hayao";
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      hayao = import ../../home-manager/wsl;
    };
  };

  system.stateVersion = "24.11";
}
