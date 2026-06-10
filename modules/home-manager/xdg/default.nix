{
  config,
  lib,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      desktop = "${homeDir}/Desktop";
      documents = "${homeDir}/Documents";
      download = "${homeDir}/Downloads";
      music = "${homeDir}/Music";
      pictures = "${homeDir}/Pictures";
      publicShare = "${homeDir}/Public";
      templates = "${homeDir}/Templates";
      videos = "${homeDir}/Videos";
    };
    configFile."user-dirs.dirs".force = true;
  };
}
