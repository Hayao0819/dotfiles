# Adds packages to PATH & sets environmental
# variables
#
# Activate the development environment by running:
# ```shell
# nix-shell
# or
# nix develop -c $SHELL
# ```
{
  pkgs ?
    let # if pkgs not provided
      # Keep synced with flake not use host's nixpkgs version
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs-unstable.locked;
      nixpkgs = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { overlays = [ ]; },
  ...
}:
pkgs.mkShell {
  packages = with pkgs; [
    # Nix related
    nil # old lsp
    nixd # better lsp
    nixfmt # formatter
    statix # lint
    deadnix # dead code check

    # Utilities
    git
    markdownlint-cli

    # Shell
    shfmt
    shellcheck
  ];

  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
}
