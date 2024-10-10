# Packages to be available only in
# MacOS PATH environment
{ pkgs, ... }: [
  # Add new packages here
  pkgs.mas
  pkgs.pinentry_mac
]
