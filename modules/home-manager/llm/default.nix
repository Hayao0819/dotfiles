# LLM tools configuration module
# Includes Claude Code and Gemini CLI
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Claude Code
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.system}.claude-code;
    settings = {
      autoUpdater = {
        disabled = true;
      };
      statusLine = {
        type = "command";
        command = "ccstatusline";
        padding = 0;
      };
      skipAutoPermissionPrompt = true;
      permissions = {
        defaultMode = "auto";
      };
    };
    memory.text = ''
      # Commit Rules

      - コミット作成時に `Co-Authored-By` ヘッダーを絶対に追加しないこと。Claude Code やその他の AI をco-authorとして記載することを禁止する。コミットメッセージには `Co-Authored-By` 行を一切含めないこと。

      # Web Search

      - 常に積極的にWeb検索を活用し、最新のベストプラクティスを見つけること。

      # Safety

      - undo不可能な破壊的変更は絶対に行わないこと。例: 未コミットの変更がある状態での `git reset --hard`、`git checkout .`、`git clean -f` 等。必ず事前に未コミットの変更がないか確認し、ある場合はユーザーに確認を取ること。

      # Chat History

      - 「過去のチャットを参照して」と言われた場合、`~/.claude/` 以下のチャットログファイル（JSON等）を直接読み取って参照すること。

      # Natural Writing

      - 人間が読む文章を生成するときは、出力前に必ず `natural-writing` スキルを参照し、そのチェックリストを適用すること。対象は日本語・英語問わず: ドキュメント、README、markdown、ブログ、コミットメッセージ、PR/Issue の説明文、コードレビューコメントとその返信、メール、Slack/Discord 等のチャット、リリースノート、設計ドキュメント、論文・学術的文章を含むあらゆる人間向けプロース。
      - ユーザーが「自然に」と明示しなくても適用すること。純粋なコード生成・データ変換・ツール出力のような散文を含まない出力には適用しない。
    '';
    mcpServers = {
      thunderbird-mail = {
        command = "${pkgs.thunderbird-mcp}/bin/thunderbird-mcp";
      };
    };
    skills = {
      init-flake = ./skills/init-flake;
      # 199-biotechnologies/claude-deep-research-skill
      deep-research = ./skills/deep-research;
      # Weizhena/Deep-Research-skills
      research = ./skills/research;
      research-add-fields = ./skills/research-add-fields;
      research-add-items = ./skills/research-add-items;
      research-deep = ./skills/research-deep;
      research-report = ./skills/research-report;
      natural-writing = ./skills/natural-writing;
    };
    agents = {
      # Weizhena/Deep-Research-skills
      web-search-agent = ./agents/web-search-agent.md;
    };
  };

  # web-search-agent modules (referenced by the agent via ~/.claude/agents/web-search-modules/)
  home.file.".claude/agents/web-search-modules" = {
    source = ./agents/web-search-modules;
    recursive = true;
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

  # Claude Code flicker-free fullscreen rendering
  home.sessionVariables = {
    CLAUDE_CODE_NO_FLICKER = "1";
  };

  # LLM-related packages
  home.packages = [
    inputs.llm-agents.packages.${pkgs.system}.ccstatusline
    pkgs.gemini-cli
  ];
}
