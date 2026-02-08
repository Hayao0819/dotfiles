# Steam gaming platform configuration
{ pkgs, ... }:

{
  # Enable Steam
  programs.steam = {
    enable = true;
    # Enable Steam's remote play feature
    remotePlay.openFirewall = true;
    # Enable Steam's dedicated server feature
    dedicatedServer.openFirewall = true;
    # Enable Steam's local network game transfers
    localNetworkGameTransfers.openFirewall = true;
  };

  # Enable GameMode for optimized gaming performance
  programs.gamemode.enable = true;

  # Hardware support for game controllers
  hardware.steam-hardware.enable = true;
}
