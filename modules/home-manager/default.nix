# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{ inputs }:
with builtins;
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (mod: {
  name = mod;
  value = import "${inputs.self}/modules/home-manager/${mod}";
})
|> listToAttrs

# {
#   # List your module files here
#   git = import ./git;
#   zsh = import ./zsh;
#   fish = import ./fish;
#   pkgs = import ./pkgs;
#   gnome = import ./gnome;
#   gh = import ./gh;
#   wallpapers = import ./wallpapers;
#   llm = import ./llm;
#   xdg = import ./xdg;
#   theme = import ./theme;
#   audio = import ./audio;
#   osint = import ./osint;
# }
