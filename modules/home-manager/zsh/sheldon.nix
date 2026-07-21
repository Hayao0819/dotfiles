_: {
  programs.sheldon = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = false;
    enableBashIntegration = false;

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
}
