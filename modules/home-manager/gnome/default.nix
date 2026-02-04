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

  # Workaround for Chromium bug: NoDisplay=true at end of .desktop file is ignored
  # https://issues.chromium.org/issues/467443999
  xdg.desktopEntries."com.brave.Browser" = {
    name = "Brave Web Browser";
    exec = "brave %U";
    icon = "brave-browser";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    settings = {
      NoDisplay = "true";
    };
  };
}
