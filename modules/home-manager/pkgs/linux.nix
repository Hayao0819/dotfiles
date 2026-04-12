# Packages to be available only in
# Linux PATH environment
{ pkgs, ... }:
[
  # Add new packages here
  pkgs.docker-compose
  pkgs.pinentry-gnome3
  pkgs.dconf2nix

  # JavaScript tool manager
  pkgs.volta
]
