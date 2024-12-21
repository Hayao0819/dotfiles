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

        # Enable the Gnome desktop environment.
        displayManager.gdm.enable = true;
        desktopManager.gnome = {
          enable = true;
        };
      };
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
      gnome.yelp
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

    # Enabling seahorse keyring
    programs.seahorse = {
      enable = true;
    };

    # Install packages
    environment.systemPackages = with pkgs; [
      dconf-editor
      gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
      gnomeExtensions.arcmenu
      gnomeExtensions.dash-to-panel
    ];
  };
}
