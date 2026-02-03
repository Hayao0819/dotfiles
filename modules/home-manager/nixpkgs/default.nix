# Home Manager nixpkgs configuration module
# Provides unified nixpkgs settings for Home Manager
{ inputs, outputs, ... }:
{
  # Apply overlays and configuration to Home Manager
  nixpkgs = {
    # Add overlays
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    # Configure nixpkgs
    config = {
      # Allow unfree packages
      allowUnfree = true;

      # Allow unsupported system
      allowUnsupportedSystem = true;
    };
  };
}