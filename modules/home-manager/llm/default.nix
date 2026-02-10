# LLM tools configuration module
# Includes Claude Code and Gemini CLI
{ pkgs, ... }:
{
  # Claude Code
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

  # Gemini CLI (from llm-agents overlay)
  home.packages = [
    pkgs.gemini-cli
  ];
}
