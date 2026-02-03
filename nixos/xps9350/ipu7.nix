# Intel IPU7 Camera Support Module
# Based on NixOS PR #479283 (https://github.com/NixOS/nixpkgs/pull/479283)
# This module provides support for Intel IPU7/MIPI cameras on Lunar Lake systems.
#
# Remove this file and use hardware.ipu7 directly once PR #479283 is merged into nixpkgs.
{
  config,
  lib,
  pkgs,
  ...
}:
let

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    optional
    types
    ;

  cfg = config.hardware.ipu7;

in
{

  options.hardware.ipu7 = {

    enable = mkEnableOption "support for Intel IPU7/MIPI cameras";

    platform = mkOption {
      type = types.enum [
        "ipu7x"
        "ipu75xa"
      ];
      description = ''
        Choose the version for your hardware platform.

        - ipu7x (Lunar Lake)
          Sensor list: https://github.com/intel/ipu7-camera-hal/tree/main/config/linux/ipu7x/sensors
        - ipu75xa (Lunar Lake)
          Sensor list: https://github.com/intel/ipu7-camera-hal/tree/main/config/linux/ipu75xa/sensors
      '';
    };

  };

  config = mkIf cfg.enable {

    # Module is upstream as of 6.17,
    # https://www.phoronix.com/news/Intel-IPU7-Firmware-Upstreamed
    # boot.extraModulePackages is not needed when using kernel >= 6.17

    hardware.firmware = with pkgs; [
      ipu7-camera-bins
      ivsc-firmware
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="intel-ipu7-psys", MODE="0660", GROUP="video"
    '';

    services.v4l2-relayd.instances.ipu7 = {
      enable = mkDefault true;

      cardLabel = mkDefault "Intel MIPI Camera";

      # Use packages from our overlay (from PR #479283)
      extraPackages =
        with pkgs.gst_all_1;
        [ ]
        ++ optional (cfg.platform == "ipu7x") pkgs.icamerasrc-ipu7x
        ++ optional (cfg.platform == "ipu75xa") pkgs.icamerasrc-ipu75xa;

      input = {
        pipeline = "icamerasrc";
        # Output Formats - NV12, NV16, I420, M420, YUY2, YUYV, P010, P016
        format = "NV12";
      };
    };
  };
}
