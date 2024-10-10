{ config
, pkgs
, lib
, ...
}: {
  options = {
    git = {
      isMacOS = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install MacOS specific agent.";
      };
    };
  };

  config = {
    # Git Configurations
    programs.git = {
      enable = true;
      lfs.enable = true;

      # User credentials
      userName = "hayao";
      userEmail = "shun819.mail@gmail.com";

      extraConfig = {
        http.sslVerify = false;
      };

      # GPG Signing
      signing = {
        signByDefault = false;
        key = "";
      };

      # Aliases
      #aliases = {
      #  ch = "checkout";
      #};

      # Git ignores
      ignores = [
        ".DS_Store"
      ];
    };

    home.file.".gnupg/gpg-agent.conf".text =
      if config.git.isMacOS
      then ''
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      ''
      # TODO: Change kwallet to gnome keyring
      else ''
        pinentry-program ${pkgs.kwalletcli}/bin/pinentry-kwallet
      '';

    home.file.".gnupg/gpg.conf".text =
      if config.git.isMacOS
      then ''
        no-tty
        use-agent
        auto-key-retrieve
        no-emit-version
      ''
      else ''
      '';
  };
}
