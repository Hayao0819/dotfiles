{ pkgs, ... }:

{
  config = {
    # Enable Hyprland compositor
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # XDG Desktop Portal for Hyprland (screen sharing, file dialogs, etc.)
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    # Essential packages for Hyprland
    environment.systemPackages = with pkgs; [
      # Terminal (required for default Hyprland config)
      kitty

      # Application launcher
      wofi

      # Notification daemon
      mako

      # Status bar
      waybar

      # Wallpaper
      hyprpaper

      # Screen locking
      hyprlock

      # Idle daemon
      hypridle

      # Screenshot tools
      grim
      slurp

      # Clipboard
      wl-clipboard

      # Brightness control
      brightnessctl

      # Audio control (pavucontrol for GUI)
      pavucontrol

      # File manager (if not using GNOME's nautilus)
      # pcmanfm
    ];

    # Hint Electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Enable polkit for privilege escalation (usually enabled by GNOME, but ensure it's there)
    security.polkit.enable = true;
  };
}
