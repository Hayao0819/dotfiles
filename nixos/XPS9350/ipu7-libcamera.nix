# Intel IPU7 Camera Support Module - libcamera backend
# Based on NixOS PR #479283 (https://github.com/NixOS/nixpkgs/pull/479283)
# This module provides support for Intel IPU7/MIPI cameras on Lunar Lake systems
# using libcamera as the camera access method.
#
# libcamera works with the in-tree kernel module (6.17+) because it interfaces
# directly with V4L2/media-ctl without using the Intel camera HAL (libcamhal).
#
# Requires intel_cvs kernel module from intel/vision-drivers for sensor power control.
# See: https://github.com/intel/vision-drivers
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
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.hardware.ipu7;

  # Build intel_cvs kernel module for the current kernel
  intel-cvs = pkgs.callPackage ../../pkgs/intel-cvs {
    kernel = config.boot.kernelPackages.kernel;
  };
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

    # Add intel_cvs kernel module for camera sensor power control
    boot.extraModulePackages = [ intel-cvs ];

    # Load modules in correct order:
    # 1. mei_vsc - Intel Vision Security Controller MEI interface
    # 2. intel_cvs - Intel Computer Vision Services (powers camera sensors)
    # 3. ov02c10 will be auto-loaded when sensor is detected
    boot.kernelModules = [
      "mei_vsc"
      "intel_cvs"
    ];

    hardware.firmware = with pkgs; [
      ipu7-camera-bins
      ivsc-firmware
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="intel-ipu7-psys", MODE="0660", GROUP="video"
    '';

    # Install libcamera for camera access (v0.7.0+ required for ov02c10)
    # Applications using libcamera (e.g., cam, pipewire-camera) will work directly
    environment.systemPackages = [ pkgs.unstable.libcamera ];

    # Override PipeWire to use unstable version with libcamera 0.7.0+ support
    # This enables WirePlumber to detect IPU7 cameras via libcamera
    services.pipewire.package = pkgs.unstable.pipewire;
    services.pipewire.wireplumber.package = pkgs.unstable.wireplumber;
  };
}
