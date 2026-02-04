# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: { };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
    };
  };

  # llm-agents packages (ccstatusline, etc.)
  llm-agents = inputs.llm-agents.overlays.default;

  # IPU7 camera packages from PR #479283
  # Remove this overlay once the PR is merged into nixpkgs
  ipu7-packages = final: prev:
    let
      ipu7-pkgs = import inputs.nixpkgs-ipu7 {
        system = final.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
        };
      };
    in {
      inherit (ipu7-pkgs)
        ipu7-camera-bins
        ipu7-camera-hal-ipu7x
        ipu7-camera-hal-ipu75xa
        ;
      # icamerasrc is in gst_all_1 namespace
      inherit (ipu7-pkgs.gst_all_1)
        icamerasrc-ipu7x
        icamerasrc-ipu75xa
        ;
    };
}
