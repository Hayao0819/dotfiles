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
  entryCount = config.boot.loader.minegrubEntryCount;

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
      # The bottom bar sits below the entry list, so its offset has to track the
      # number of entries; the theme cannot compute this at boot time.
      top_value=$((170 + (${toString entryCount} - 2) * 72))
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

  options.boot.loader.minegrubEntryCount = lib.mkOption {
    type = lib.types.ints.positive;
    default = 5;
    description = ''
      Number of top-level GRUB entries the minegrub theme is laid out for,
      counting the two NixOS adds itself. Keep in sync with extraEntries or the
      bottom bar is drawn in the wrong place.
    '';
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
        # os-prober records the other OS's kernels as they were at rebuild time,
        # so a kernel installed there afterwards never shows up. Hosts declare
        # their foreign entries in extraEntries instead.
        useOSProber = false;
        efiSupport = true;
        default = "saved";

        # Custom minegrub theme with wider buttons
        theme = "${customMinegrubTheme}/grub/themes/minegrub";
        splashImage = "${customMinegrubTheme}/grub/themes/minegrub/background.png";
      };
    })

    # systemd-boot configuration
    (lib.mkIf (cfg == "systemd-boot") {
      boot.loader.systemd-boot.enable = true;
    })
  ];
}
