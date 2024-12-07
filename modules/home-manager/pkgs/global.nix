# List of packages to be available in PATH for
# both MacOS and Linux.
{ pkgs, ... }: [
  # Downloader
  pkgs.aria

  # Developer Mode
  pkgs.jq
  pkgs.wget
  pkgs.git-lfs

  # Environment
  pkgs.fd
  pkgs.bat
  pkgs.btop
  pkgs.gping
  pkgs.fastfetch
  pkgs.procs
  pkgs.ripgrep
  pkgs.tealdeer
  pkgs.topgrade

  # GPG Signing
  pkgs.gnupg

  # Selfmade programs
  pkgs.hello
  pkgs.roulette
]
