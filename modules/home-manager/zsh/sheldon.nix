{ pkgs, ... }: {
  home.packages = with pkgs; [
    sheldon
  ];

  home.file = {
    ".config/sheldon/plugins.toml".source = ./plugins.toml;
  };
}
