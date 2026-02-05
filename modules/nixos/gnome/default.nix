{ pkgs, ... }:

{
  config = {
    # Enable the X11 windowing system.
    services = {
      xserver = {
        enable = true;

        # Configure keymap in X11
        xkb = {
          variant = "";
          layout = "us";
        };

        # Exclude some defautl packages
        excludePackages = [ pkgs.xterm ];
      };

      # Enable the GDM display manager
      displayManager.gdm = {
        enable = true;
      };

      # Enable the GNOME desktop environment
      desktopManager.gnome.enable = true;
    };

    # Make sure opengl is enabled
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      xterm
      firefox
      gnome-photos
      gnome-tour
      gedit # text editor
      yelp
      gnome-logs # system log viewer
      gnome-calculator # calculator
      gnome-disk-utility # disk management tool
      gnome-weather # 天気
      gnome-maps # 地図
      gnome-contacts # 連絡先
      gnome-connections # 接続
      decibels # audio player
      showtime # video player
      papers # document viewer (evince successor)
      gnome-calendar # calendar
      loupe # image viewer
      simple-scan # scanner tool
    ];

    # Setting daemons
    services = {
      # Udev daemon management
      udev.packages = with pkgs; [ gnome-settings-daemon ];
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Enable the DConf configuration system.
    programs.dconf.enable = true;

    # Enable GNOME Keyring (required for VS Code Settings Sync)
    services.gnome.gnome-keyring.enable = true;

    # Enabling seahorse keyring
    programs.seahorse = {
      enable = true;
    };

    # Install packages
    environment.systemPackages = (with pkgs; [
      # GNOME tools
      dconf-editor
      gnome-tweaks

      # Icon theme
      papirus-icon-theme

      # GNOME Shell extensions
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
      gnomeExtensions.dash-to-panel
      gnomeExtensions.kimpanel
      gnomeExtensions.status-icons
      gnomeExtensions.user-themes
      # gnomeExtensions.pano # Archived, doesn't support GNOME 49
      gnomeExtensions.desktop-icons-ng-ding
    ]) ++ (with pkgs.unstable; [
      gnomeExtensions.arcmenu
      gnomeExtensions.copyous # Pano successor - supports images, links, colors

      # Copyous runtime dependencies (loaded via GObject Introspection)
      libgda6 # SQLite database access for clipboard history
      gsound # Sound playback (optional)
    ]);
  };
}
