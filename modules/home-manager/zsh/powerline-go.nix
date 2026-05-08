{ ... }:
{
  programs.powerline-go = {
    enable = true;
    newline = true;
    settings = {
      hostname-only-if-ssh = true;
    };
  };
}
