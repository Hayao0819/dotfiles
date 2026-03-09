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
    memory.text = ''
      # Commit Rules

      - コミット作成時に `Co-Authored-By` ヘッダーを絶対に追加しないこと。Claude Code やその他の AI をco-authorとして記載することを禁止する。コミットメッセージには `Co-Authored-By` 行を一切含めないこと。
    '';
    skills = {
      init-flake = ./skills/init-flake.md;
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

  # LLM-related packages (from llm-agents overlay)
  home.packages = [
    pkgs.llm-agents.ccstatusline
    pkgs.gemini-cli
  ];
}
