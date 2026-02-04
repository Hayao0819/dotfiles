# Centralized nixpkgs configuration
# This module provides unified nixpkgs settings for all systems
{ outputs, ... }:
{
  # Common nixpkgs configuration
  nixpkgs = {
    # Add overlays
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.ipu7-packages # IPU7 camera support (PR #479283)
      outputs.overlays.llm-agents # llm-agents packages (ccstatusline, etc.)
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
