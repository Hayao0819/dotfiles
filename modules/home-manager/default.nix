# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  git = import ./git;
  zsh = import ./zsh;
  fish = import ./fish;
  pkgs = import ./pkgs;
  gnome = import ./gnome;
  vscode = import ./vscode;
  gh = import ./gh;
  wallpapers = import ./wallpapers;
  claude = import ./claude;
  xdg = import ./xdg;
  theme = import ./theme;
  audio = import ./audio;
}
