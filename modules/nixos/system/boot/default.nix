# Boot loader configuration module
# Supports both GRUB and systemd-boot
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.boot.loader.type;

  # Custom minegrub theme with wider buttons
  customMinegrubTheme = pkgs.stdenv.mkDerivation {
    name = "minegrub-theme-custom";
    src = pkgs.fetchFromGitHub {
      owner = "Lxtharia";
      repo = "minegrub-theme";
      rev = "2fa2012472fbfcfea17b82655dd27456fa507ee7";
      sha256 = "sha256-GvlAAIpM/iZtl/EtI+LTzEsQ2qlUkex9i4xRUZXmadM=";
    };

    patchPhase = ''
      # Adjust top position for 5 boot options
      top_value=$((170 + (5 - 2) * 72))
      sed -i '/^+ image {/,/^}$/s/top = 40%+[0-9]\+/top = 40%+'"$top_value"'/' minegrub/theme.txt

      # Increase button width from 600 to 800
      sed -i 's/width = 600/width = 800/g' minegrub/theme.txt
      sed -i 's/left = 50%-297/left = 50%-397/g' minegrub/theme.txt
      sed -i 's/left = 50%-300/left = 50%-400/g' minegrub/theme.txt
    '';

    installPhase = ''
      cd minegrub
      mkdir -p $out/grub/themes/minegrub
      cp *.png $out/grub/themes/minegrub
      cp *.pf2 $out/grub/themes/minegrub
      cp theme.txt $out/grub/themes/minegrub
    '';
  };
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

        # Custom minegrub theme with wider buttons
        theme = "${customMinegrubTheme}/grub/themes/minegrub";
        splashImage = "${customMinegrubTheme}/grub/themes/minegrub/background.png";

        # Remove device names from os-prober entries (e.g., "(on /dev/nvme0n1p2)")
        # Uses extraInstallCommands to run AFTER grub.cfg is generated
        extraInstallCommands = ''
          ${pkgs.gnused}/bin/sed -i \
            -e "s/menuentry '\([^']*\) (on \/dev\/[^)]*)/menuentry '\1/g" \
            -e "s/submenu '\([^']*\) (on \/dev\/[^)]*)/submenu '\1/g" \
            /boot/grub/grub.cfg
        '';
      };
    })

    # systemd-boot configuration
    (lib.mkIf (cfg == "systemd-boot") {
      boot.loader.systemd-boot.enable = true;
    })
  ];
}
