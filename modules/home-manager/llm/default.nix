# LLM tools configuration module
# Includes Claude Code and Gemini CLI
{ pkgs, lib, ... }:
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

  # ccstatusline configuration
  xdg.configFile."ccstatusline/settings.json".text = builtins.toJSON {
    version = 3;
    lines = [
      [
        {
          id = "1";
          type = "model";
          color = "cyan";
        }
        {
          id = "2";
          type = "separator";
        }
        {
          id = "3";
          type = "context-percentage";
          color = "blue";
        }
        {
          id = "4";
          type = "separator";
        }
        {
          id = "5";
          type = "git-branch";
          color = "magenta";
        }
        {
          id = "6";
          type = "separator";
        }
        {
          id = "7";
          type = "git-changes";
          color = "yellow";
        }
      ]
      [ ]
      [ ]
    ];
    flexMode = "full-minus-40";
    compactThreshold = 60;
    colorLevel = 2;
    inheritSeparatorColors = false;
    globalBold = false;
    powerline = {
      enabled = false;
      separators = [ "" ];
      separatorInvertBackground = [ false ];
      startCaps = [ ];
      endCaps = [ ];
      autoAlign = false;
    };
  };

  # Gemini CLI (from llm-agents overlay)
  home.packages = [
    pkgs.gemini-cli
  ];
}
