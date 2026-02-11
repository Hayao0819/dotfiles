# OSINT (Open Source Intelligence) tools module
{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    osint = {
      enable = lib.mkEnableOption "OSINT tools collection";

      # Username/Account investigation tools
      sherlock.enable = lib.mkEnableOption "Sherlock - hunt usernames across social networks";
      maigret.enable = lib.mkEnableOption "Maigret - collect details about usernames";
      holehe.enable = lib.mkEnableOption "Holehe - check if email is used on different sites";
      ghunt.enable = lib.mkEnableOption "GHunt - Google account investigation";
    };
  };

  config = lib.mkIf config.osint.enable {
    home.packages =
      with pkgs;
      [ ]
      ++ lib.optionals config.osint.sherlock.enable [ sherlock ]
      ++ lib.optionals config.osint.maigret.enable [ maigret ]
      ++ lib.optionals config.osint.holehe.enable [ holehe ]
      ++ lib.optionals config.osint.ghunt.enable [ ghunt ];
  };
}
