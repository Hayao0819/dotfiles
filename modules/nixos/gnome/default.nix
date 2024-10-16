{pkgs, ...}: {
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
        excludePackages = [pkgs.xterm];

        # Enable the Gnome desktop environment.
        displayManager.gdm.enable = true;
        desktopManager.gnome = {
          enable = true;
        };
      };
    };

    # Make sure opengl is enabled
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Exclude some packages from the Gnome desktop environment.
    environment.gnome.excludePackages =
      (with pkgs; [
        xterm
        firefox
      ])
      ++ (with pkgs.gnome; [
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        # epiphany # web browser
      ]);

    # Setting daemons
    services = {
      # Udev daemon management
      udev.packages = with pkgs; [gnome.gnome-settings-daemon];
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

    # Enable the Gnome Tweaks tool.
    environment.systemPackages = with pkgs; [
      gnome.dconf-editor
      gnome.gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-dock
      gnomeExtensions.gsconnect
    ];
  };
}
