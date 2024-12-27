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

    settings."org/gnome/shell/extensions/arcmenu" = {
      hide-overview-on-startup = true;
    };

    settings."ca/desrt/dconf-editor" = {
      show-warning-dialog = false;
    };

    settings."org/gnome/shell/extensions/dash-to-panel" = {
      panel-element-positions = {
        "0" = [
          {
            "element" = "showAppsButton";
            "visible" = false;
            "position" = "stackedTL";
          }
          {
            "element" = "activitiesButton";
            "visible" = false;
            "position" = "stackedTL";
          }
          {
            "element" = "leftBox";
            "visible" = true;
            "position" = "stackedTL";
          }
          {
            "element" = "taskbar";
            "visible" = true;
            "position" = "stackedTL";
          }
          {
            "element" = "centerBox";
            "visible" = true;
            "position" = "stackedBR";
          }
          {
            "element" = "rightBox";
            "visible" = true;
            "position" = "stackedBR";
          }
          {
            "element" = "systemMenu";
            "visible" = true;
            "position" = "stackedBR";
          }
          {
            "element" = "dateMenu";
            "visible" = true;
            "position" = "stackedBR";
          }
          {
            "element" = "desktopButton";
            "visible" = true;
            "position" = "stackedBR";
          }
        ];
      };
    };
  };
}
