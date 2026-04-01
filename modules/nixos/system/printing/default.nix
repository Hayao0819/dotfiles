# Printing configuration with Fujifilm Apeos C3450d support
# Uses fflinuxprint (official Fujifilm Linux driver) for ApeosPort/DocuCentre/DocuPrint series
{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      # Fujifilm official Linux driver for Apeos C3450d and other ApeosPort/DocuCentre series
      # https://www.fujifilm.com/fb/download/apeosport/1860/linux/nb_linux64
      fflinuxprint
      # CUPS filters for network printer discovery
      cups-filters
    ];
  };

  # Enable network printer auto-discovery via Avahi/mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
