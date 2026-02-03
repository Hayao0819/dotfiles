# GNOME configuration for Home Manager
# Migrated from Arch Linux dconf settings
{ lib, pkgs, ... }:

let
  inherit (lib.hm.gvariant) mkUint32 mkTuple;
in
{
  dconf = {
    enable = true;
    # Import dconf2nix generated settings
    # To update: dconf dump / | dconf2nix > modules/home-manager/gnome/dconf-generated.nix
    settings = import ./dconf-generated.nix { inherit mkUint32 mkTuple; };
  };
}
