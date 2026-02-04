# Claude Code configuration module
{ ... }:
{
  programs.claude-code = {
    enable = true;
    settings = {
      statusLine = {
        type = "command";
        command = "ccstatusline";
        padding = 0;
      };
    };
  };
}
