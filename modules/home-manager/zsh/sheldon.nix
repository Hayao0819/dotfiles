{ ... }:
{
  # @orzklv: Avoid using toml and other formats, refer to options explorer:
  # https://home-manager-options.extranix.com/?query=sheldon&release=release-25.11

  programs.sheldon = {
    enable = true;
    # Plugins below are zsh-only, so only enable zsh integration.
    # Enabling fish/bash integration causes those shells to source
    # zsh plugin files at startup and fail with parse errors.
    enableZshIntegration = true;
    enableFishIntegration = false;
    enableBashIntegration = false;

    # `sheldon` configuration file
    # ----------------------------
    #
    # You can modify this file directly or you can use one of the following
    # `sheldon` commands which are provided to assist in editing the config file:
    #
    # - `sheldon add` to add a new plugin to the config file
    # - `sheldon edit` to open up the config file in the default editor
    # - `sheldon remove` to remove a plugin from the config file
    #
    # See the documentation for more https://github.com/rossmacarthur/sheldon#readme
    #
    # @orzklv: hey, you can use our toml to nix :)
    # https://xinux.uz/utils/toml2nix
    settings = {
      shell = "zsh";
      plugins = {
        zsh-autosuggestions = {
          github = "zsh-users/zsh-autosuggestions";
        };
        zsh-history-substring-search = {
          github = "zsh-users/zsh-history-substring-search";
        };
        zsh-syntax-highlighting = {
          github = "zsh-users/zsh-syntax-highlighting";
        };
      };
    };
  };

  # home.packages = with pkgs; [
  #   sheldon
  # ];

  # home.file = {
  #   ".config/sheldon/plugins.toml".source = ./plugins.toml;
  # };
}
