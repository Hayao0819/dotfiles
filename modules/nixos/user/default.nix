# User-level NixOS modules
# These configure desktop environments, user applications, and user-facing features
{
  apps = import ./apps;
  archtools = import ./archtools;
  fcitx5 = import ./fcitx5;
  gnome = import ./gnome;
  hyprland = import ./hyprland;
  steam = import ./steam;
}
