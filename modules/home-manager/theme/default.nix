# Unified GTK/Qt theming with Colloid
{ pkgs, config, ... }:

let
  # Colloid KDE/Kvantum theme (not in nixpkgs)
  colloid-kde-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "colloid-kde-theme";
    version = "unstable-2025-01-29";

    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Colloid-kde";
      rev = "b768904d10ba9fcb95abfb59538eab100b1fed1e";
      hash = "sha256-CWa6HnMP042jh573/x7WxYyRScN/l+jjCasiaBODljA=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/Kvantum
      cp -r Kvantum/* $out/share/Kvantum/

      runHook postInstall
    '';
  };
in
{
  # GTK theme configuration
  gtk = {
    enable = true;

    theme = {
      name = "Colloid-Dark-Nord";
      package = pkgs.colloid-gtk-theme.override {
        colorVariants = [ "dark" ];
        tweaks = [ "nord" ];
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # GTK2 settings
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme=1
    '';

    # GTK3 settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    # GTK4 settings
    gtk4.theme = config.gtk.theme;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt theming with Kvantum
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # Kvantum configuration - use Colloid Nord theme
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=ColloidNord
  '';

  # Install Kvantum and Colloid-kde theme
  # Qt packages are only needed when qt module manages them (not on Arch where pacman does)
  home.packages = [
    # Colloid Kvantum theme
    colloid-kde-theme
  ]
  ++ pkgs.lib.optionals config.qt.enable [
    # Kvantum theme engine
    pkgs.kdePackages.qtstyleplugin-kvantum
    pkgs.libsForQt5.qtstyleplugin-kvantum

    # Qt configuration tools
    pkgs.libsForQt5.qt5ct
    pkgs.kdePackages.qt6ct
  ];
}
