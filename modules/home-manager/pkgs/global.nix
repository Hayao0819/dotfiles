# List of packages to be available in PATH for
# both MacOS and Linux.
{ pkgs, llm-agents-pkgs, ... }: [
  # Claude Code statusline
  llm-agents-pkgs.ccstatusline
  # Downloader
  pkgs.aria2

  # Developer Mode
  pkgs.jq
  pkgs.wget
  pkgs.git-lfs

  # Code linters and formatters
  pkgs.markdownlint-cli
  pkgs.shfmt
  pkgs.shellcheck

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
  # pkgs.hello
  # pkgs.roulette

  pkgs.nil
  pkgs.nixpkgs-fmt
]
