# Adds packages to PATH & sets environmental
# variables
#
# Activate the development environment by running:
# ```shell
# nix-shell
# ```
{ pkgs ? let # if pkgs not provided
    # Keep synced with flake not use host's nixpkgs version
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }
, ...
}: pkgs.stdenv.mkDerivation {
  name = "hayanix";

  nativeBuildInputs = with pkgs; [
    nil
    nixpkgs-fmt
    git
    markdownlint-cli
    shfmt
    shellcheck
  ];

  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
}
