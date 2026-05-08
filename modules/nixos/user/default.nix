# User-level NixOS modules
# These configure desktop environments, user applications, and user-facing features
{ inputs }:
with builtins;
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (mod: {
  name = mod;
  value = import "${inputs.self}/modules/nixos/user/${mod}";
})
|> listToAttrs

# {
#   apps = import ./apps;
#   archtools = import ./archtools;
#   fcitx5 = import ./fcitx5;
#   gnome = import ./gnome;
#   hyprland = import ./hyprland;
#   steam = import ./steam;
# }
