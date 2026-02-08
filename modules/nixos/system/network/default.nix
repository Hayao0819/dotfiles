# Network configuration for NixOS
{ pkgs, ... }:
{
  # Enable networking
  networking.networkmanager = {
    enable = true;

    # VPN plugins for NetworkManager GUI
    plugins = with pkgs; [
      networkmanager-openvpn # OpenVPN support
    ];
  };

  # OpenVPN client package
  environment.systemPackages = with pkgs; [
    openvpn
  ];
}
