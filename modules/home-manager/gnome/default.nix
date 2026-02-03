# GNOME configuration for Home Manager
# Migrated from Arch Linux dconf settings
{ lib, pkgs, ... }:

with lib.hm.gvariant;

{
  dconf = {
    enable = true;
    # Import dconf2nix generated settings
    # To update: dconf dump / | dconf2nix > modules/home-manager/gnome/dconf-generated.nix
    settings = import ./dconf-generated.nix;
  };
}
