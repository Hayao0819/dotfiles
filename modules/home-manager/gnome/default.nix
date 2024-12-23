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

    # Power management
    settings."org/gnome/settings-daemon/plugins/power" = {
      power-saver-profile-on-low-battery = false;
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-battery-timeout = 0;
    };

    settings."org/gnome/shell/extensions/arcmenu" ={
      hide-overview-on-startup = true;
    }

    settings."ca/desrt/dconf-editor" = {
      show-warning-dialog = false;
    };
  };
}
