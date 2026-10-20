# Home Manager configuration for Asahi Linux on Apple Silicon
{ ... }:
{
  imports = [ ../debian ];

  # Keep GNOME settings managed by the desktop, outside Nix.
  dconf.enable = false;
}
