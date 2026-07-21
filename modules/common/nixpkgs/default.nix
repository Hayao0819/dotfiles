# Centralized nixpkgs configuration
# This module provides unified nixpkgs settings for all systems
{ outputs, ... }:
{
  # Common nixpkgs configuration
  nixpkgs = {
    # Add overlays
    overlays = [
      outputs.overlays.additions
      outputs.overlays.unstable-packages
      outputs.overlays.modifications
      outputs.overlays.ipu7-packages # IPU7 camera support (PR #479283)
      outputs.overlays.os-prober-fix # Fix lsblk warnings in os-prober
    ];

    # Configure nixpkgs
    config = {
      # Allow unfree packages
      allowUnfree = true;

      # Allow unsupported system (for cross-compilation, etc.)
      allowUnsupportedSystem = true;

      # Allow specific insecure packages
      # qtwebengine is required by globalprotect-openconnect
      permittedInsecurePackages = [
        "qtwebengine-5.15.19"
        "python3.12-pypdf2-3.0.1" # required by maigret
      ];
    };
  };
}
