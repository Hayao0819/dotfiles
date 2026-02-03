# Centralized nixpkgs configuration
# This module provides unified nixpkgs settings for all systems
{ inputs, outputs, ... }:
{
  # Common nixpkgs configuration
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

      # Allow unsupported system (for cross-compilation, etc.)
      allowUnsupportedSystem = true;

      # Additional package configuration can go here
    };
  };
}