{
  ...
}:
{
  # GitHub CLI Configuration
  programs.gh = {
    enable = true;

    # Git credential helper integration
    gitCredentialHelper = {
      enable = true;
      hosts = [
        "https://github.com"
        "https://gist.github.com"
      ];
    };

    # General settings
    settings = {
      git_protocol = "ssh";
      editor = "";
    };
  };
}
