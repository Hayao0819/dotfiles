{ pkgs, ... }:
{
  dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      # Enable dark mode
      disable-user-extensions = false;

      # Enable extensions
      enabled-extensions = with pkgs.gnomeExtensions; [
        gsconnect.extensionUuid
        arcmenu.extensionUuid
        dash-to-panel.extensionUuid
        appindicator.extensionUuid
      ];
    };

    # Enable dark mode
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
