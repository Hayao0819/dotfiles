# Intel IPU7 Camera Support Module - icamerasrc/v4l2-relayd backend
# Based on NixOS PR #479283 (https://github.com/NixOS/nixpkgs/pull/479283)
# This module provides v4l2-relayd integration using icamerasrc GStreamer plugin.
#
# IMPORTANT: icamerasrc requires the OUT-OF-TREE ipu7-drivers kernel module.
# The in-tree module (kernel 6.17+) causes crashes in PipeManager::configure.
# See: https://github.com/NixOS/nixpkgs/pull/479283
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
    optional
    ;

  cfg = config.hardware.ipu7;
  icamerasrcCfg = config.hardware.ipu7.icamerasrc;

  # Platform-specific camera HAL package
  camera-hal = if cfg.platform == "ipu7x" then pkgs.ipu7x-camera-hal else pkgs.ipu75xa-camera-hal;

  # Out-of-tree ipu7-drivers from PR #479283
  # Required because in-tree module (kernel 6.17+) crashes with icamerasrc
  ipu7-drivers = pkgs.linuxPackages_ipu7.ipu7-drivers.override {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{

  options.hardware.ipu7.icamerasrc = {
    enable = mkEnableOption ''
      icamerasrc/v4l2-relayd backend for Intel IPU7 cameras.

      WARNING: This requires out-of-tree ipu7-drivers kernel module.
      The in-tree kernel module (6.17+) crashes with icamerasrc.
      This module will blacklist the in-tree modules and use out-of-tree ones.
    '';
  };

  config = mkIf (cfg.enable && icamerasrcCfg.enable) {

    # Use out-of-tree ipu7-drivers instead of in-tree modules
    # The in-tree module causes crashes in PipeManager::configure
    boot.extraModulePackages = [ ipu7-drivers ];

    # Blacklist in-tree IPU7 modules to force use of out-of-tree ones
    boot.blacklistedKernelModules = [
      "intel_ipu7"
      "intel_ipu7_isys"
    ];

    # Link camera HAL config files to /etc/camera (required by icamerasrc)
    environment.etc."camera/${cfg.platform}".source = "${camera-hal}/etc/camera/${cfg.platform}";

    # v4l2-relayd with icamerasrc creates a V4L2 loopback device
    # This allows legacy V4L2 applications to access the camera
    services.v4l2-relayd.instances.ipu7 = {
      enable = true;

      cardLabel = mkDefault "Intel MIPI Camera";

      # Use packages from our overlay (from PR #479283)
      extraPackages = [
        camera-hal
      ]
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
