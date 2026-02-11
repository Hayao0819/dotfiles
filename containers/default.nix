# Container images exported by this repository
# Build with: nix build .#container-<name>
# Example: nix build .#container-caddy
{ pkgs, ... }:
{
  caddy = pkgs.callPackage ./caddy { };
  cloudflared = pkgs.callPackage ./cloudflared { };
}
