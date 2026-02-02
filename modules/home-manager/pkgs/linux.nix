# Packages to be available only in
# Linux PATH environment
{ pkgs, ... }: [
  # Add new packages here
  pkgs.docker-compose
  pkgs.pinentry
  pkgs.dconf2nix

  # JavaScript tool manager
  pkgs.volta

  # Claude Code CLI - AI coding assistant (from unstable)
  pkgs.unstable.claude-code
]
