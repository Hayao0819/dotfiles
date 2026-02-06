# Docker configuration for NixOS
{ pkgs, ... }:
{
  # Enable Docker
  virtualisation.docker.enable = true;

  # Docker CLI and related tools
  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];
}
