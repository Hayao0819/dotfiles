# nix-ld module for running unpatched dynamic binaries
# Required for tools like volta that download pre-built binaries
{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Standard C/C++ libraries
      stdenv.cc.cc
      zlib

      # Common dependencies for Node.js and other tools
      openssl
      curl
      icu
    ];
  };
}
