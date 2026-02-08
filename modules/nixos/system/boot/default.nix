# Boot loader configuration module
# Supports both GRUB and systemd-boot
{
  config,
  lib,
  ...
}:
let
  cfg = config.boot.loader.type;
in
{
  options.boot.loader.type = lib.mkOption {
    type = lib.types.enum [
      "grub"
      "systemd-boot"
    ];
    default = "grub";
    description = "Boot loader type to use (grub or systemd-boot)";
  };

  config = lib.mkMerge [
    # Common EFI settings
    {
      boot.loader.efi.canTouchEfiVariables = true;
    }

    # GRUB configuration
    (lib.mkIf (cfg == "grub") {
      boot.loader.grub = {
        enable = true;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
        default = "saved";

        # Minegrub theme
        minegrub-theme = {
          enable = true;
          splash = "NixOS";
        };
      };
    })

    # systemd-boot configuration
    (lib.mkIf (cfg == "systemd-boot") {
      boot.loader.systemd-boot.enable = true;
    })
  ];
}
