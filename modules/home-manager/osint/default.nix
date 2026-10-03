# OSINT (Open Source Intelligence) tools module
# Note: maigret was removed due to pypdf2 CVE vulnerabilities (CVE-2026-27024 etc.)
# The following tools together provide similar capabilities:
# - sherlock: username search (~400 sites, quick lookup)
# - socialscan: accurate username/email availability check
# - sn0int: semi-automatic OSINT framework with data correlation
# - theharvester: email/domain reconnaissance
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
      socialscan.enable = lib.mkEnableOption "Socialscan - accurate username/email check on platforms";
      holehe.enable = lib.mkEnableOption "Holehe - check if email is used on different sites";
      ghunt.enable = lib.mkEnableOption "GHunt - Google account investigation";

      # Reconnaissance and data gathering
      theharvester.enable = lib.mkEnableOption "theHarvester - gather emails, subdomains from public sources";
      sn0int.enable = lib.mkEnableOption "sn0int - semi-automatic OSINT framework";
    };
  };

  config = lib.mkIf config.osint.enable {
    home.packages =
      with pkgs;
      [ ]
      ++ lib.optionals config.osint.sherlock.enable [ sherlock ]
      ++ lib.optionals config.osint.socialscan.enable [ socialscan ]
      ++ lib.optionals config.osint.holehe.enable [ holehe ]
      ++ lib.optionals config.osint.ghunt.enable [ ghunt ]
      ++ lib.optionals config.osint.theharvester.enable [ theharvester ]
      ++ lib.optionals config.osint.sn0int.enable [ sn0int ];
  };
}
