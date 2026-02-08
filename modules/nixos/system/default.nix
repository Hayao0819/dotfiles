# System-level NixOS modules
# These configure OS-level services, boot, networking, and core system behavior
{
  audio = import ./audio;
  boot = import ./boot;
  common = import ./common;
  fonts = import ./fonts;
  locale = import ./locale;
  logind = import ./logind;
  network = import ./network;
  nix-ld = import ./nix-ld;
  nixpkgs = import ./nixpkgs;
  tuned = import ./tuned;
  virtualization = import ./virtualization;
  zsh = import ./zsh;
}
