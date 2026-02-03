# Docker configuration for NixOS
{ pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    # Enable rootless mode for better security (optional)
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  # Docker CLI and related tools
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
