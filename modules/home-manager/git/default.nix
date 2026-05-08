{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    git = {
      isMacOS = lib.mkOption {
        type = lib.types.bool;
        default = pkgs.hostPlatform.isDarwin;
        description = "Install MacOS specific agent.";
      };
    };
  };

  config = {
    # Git Configurations
    programs.git = {
      enable = true;
      lfs.enable = true;

      # Settings (replaces deprecated userName, userEmail, extraConfig)
      settings = {
        user.name = "hayao";
        user.email = "shun819.mail@gmail.com";
        http.sslVerify = false;
      };

      # GPG Signing
      signing = {
        signByDefault = false;
        key = "";
      };

      # Git ignores
      ignores = [
        ".DS_Store"
      ];
    };

    home.file.".gnupg/gpg-agent.conf".text =
      if config.git.isMacOS then
        ''
          pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
        ''
      # Linux should use whatever comes with DE
      else
        "";

    home.file.".gnupg/gpg.conf".text =
      if config.git.isMacOS then
        ''
          no-tty
          use-agent
          auto-key-retrieve
          no-emit-version
        ''
      else
        "";
  };
}
