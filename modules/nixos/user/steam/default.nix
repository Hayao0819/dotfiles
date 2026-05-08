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

    # @orzklv: if you're going to do proton
    # i needed to do this when i needed to play l4d2 on nixos
    # extraCompatPackages = with pkgs; [
    #   proton-ge-bin
    # ];
    # package = pkgs.steam.override {
    #   extraPkgs =
    #     pkgs': with pkgs'; [
    #       libXcursor
    #       libXi
    #       libXinerama
    #       libXScrnSaver
    #       libpng
    #       libpulseaudio
    #       libvorbis
    #       stdenv.cc.cc.lib # Provides libstdc++.so.6
    #       libkrb5
    #       keyutils
    #       bumblebee
    #       primus
    #       # Add other libraries as needed
    #     ];
    # };

  };

  # Enable GameMode for optimized gaming performance
  programs.gamemode.enable = true;

  # Hardware support for game controllers
  hardware.steam-hardware.enable = true;
}
