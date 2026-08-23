# LLM tools configuration module
# Includes Claude Code, Codex CLI and Gemini CLI
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  codexConfig = (pkgs.formats.toml { }).generate "codex-config.toml" {
    approval_policy = "never";
    sandbox_mode = "workspace-write";
    sandbox_workspace_write = {
      network_access = true;
      writable_roots = [ config.home.homeDirectory ];
    };
  };
in
{
  # Claude Code
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    settings = {
      autoUpdater = {
        disabled = true;
      };
      cleanupPeriodDays = 3650;
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
    context = ''
      # Commit Rules

      - コミット作成時に `Co-Authored-By` ヘッダーを絶対に追加しないこと。Claude Code やその他の AI をco-authorとして記載することを禁止する。コミットメッセージには `Co-Authored-By` 行を一切含めないこと。
      - PR の作成時にも、`Created-By`、`Co-Authored-By`、`🤖 Generated with Claude Code` 等の AI 帰属の記載を一切含めないこと。PR のタイトル・本文に、Claude Code やその他の AI が作成・生成したことを示すフッターや署名を付けない。
      - コミットメッセージを書くときは `natural-writing` スキルと、そのプロジェクトの過去のコミット履歴 (`git log` を十分な件数で確認) を毎回参照し、形式・接頭辞 (例: `feat:`, `fix:`, `chore:`)・粒度・口調が既存の流れから逸脱しないよう擬態すること。過去のコミットメッセージの参照は毎回必ず行い、自分の好みではなくその履歴の書き方に合わせること。
      - コミットメッセージは原則 1 行 (subject のみ) で簡潔に完結させること。冗長な説明・箇条書き・段落の本文をだらだら書かない。変更内容を 1 行で要約できないほど大きい場合は、まずコミットを分割できないか検討すること。本文 (body) を付けるのは「なぜ」が subject だけでは絶対に伝わらず、かつ過去の履歴でも本文を付ける慣習がある場合に限り、その場合も必要最小限の行数に留めること。

      # Web Search

      - 常に積極的にWeb検索を活用し、最新のベストプラクティスを見つけること。

      # Safety

      - undo不可能な破壊的変更は絶対に行わないこと。例: 未コミットの変更がある状態での `git reset --hard`、`git checkout .`、`git clean -f` 等。必ず事前に未コミットの変更がないか確認し、ある場合はユーザーに確認を取ること。
      - ユーザーからの明示的な許可なく、以下の取り消しが困難または不可能な操作を行わないこと: `git push`、`git commit`、GitHub の PR/Issue へのコメント投稿、PR/Issue の close/reopen、PR/Issue の新規作成。ユーザーが該当操作を明示的に指示した場合のみ実行可能。それ以外は必ず事前に確認を取ること。
      - ユーザーに提案する成果物 (コミットメッセージ、PR タイトル/本文、Issue 本文、コメント文面、レビュー返信、メール等) は、実際に作成・投稿する内容と一字一句完全に一致させること。許可を求める際にサブジェクトだけ見せて本文を隠す、見出しだけ提示して詳細を後から追加する、要約だけ提示して長文を勝手に補足する等の "提案と実行の不一致" を絶対にしないこと。本文を付ける場合は本文も全文をユーザーに事前提示すること。

      # Chat History

      - 「過去のチャットを参照して」と言われた場合、`~/.claude/` 以下のチャットログファイル（JSON等）を直接読み取って参照すること。

      # Natural Writing

      - 人間が読む文章を生成するときは、出力前に必ず `natural-writing` スキル (home-manager で管理) を参照し、そのチェックリストを適用して LLM 臭い文章を回避すること。対象は日本語・英語問わず: ドキュメント、README、markdown、ブログ、コミットメッセージ、PR/Issue の説明文、コードレビューコメントとその返信、メール、Slack/Discord 等のチャット、リリースノート、設計ドキュメント、論文・学術的文章を含むあらゆる人間向けプロース。
      - ユーザーが「自然に」と明示しなくても適用すること。純粋なコード生成・データ変換・ツール出力のような散文を含まない出力には適用しない。

      # Investigation

      - わからないことは推測せず「わからない」と明示した上で、`web-search-agent` 等の調査エージェントや Web 検索、組み込みの `deep-research` ワークフローを駆使し、一次情報から事実を確認して問題解決を図ること。
      - 勝手な推測、過去の習わしの真似、それらしい記憶頼りで埋めないこと。コード・履歴・公式ドキュメント・上流の実装を一次情報として裏付けを取ってから結論を出すこと。

      # Subagent Model Selection

      - メインの会話は Opus のままにする。一方、サブエージェント (Agent/Task ツール、Workflow の `agent()`) を呼ぶときは必ず `model` を明示し、原則として安価側に振ること。既定の使い分け: 機械的な探索・ファイル読み・ログ/grep 走査・定型変換は `haiku`、Web 調査・実装・コードレビュー・要約などの実務は `sonnet`。`opus` をサブエージェントに使うのは、メインでは負えない真に高度な推論を要する単発タスクに限る。
      - 既存の調査エージェント (`web-search-agent` 等) も、呼び出し時の `model` 指定で安価側へ上書きしてよい。深掘りが必要なときだけ明示的に上げること。

      # Code Comments

      - これはすべてのエージェント・サブエージェントに適用される。既定はコメントを書かないこと。コメントは例外であり、無いと読めないコードは、まずリネームや分割で自明にできないかを先に検討する。迷ったら書かない。
      - 書きたい情報は、まず宛先を次の指針で振り分けること。コードコメント以外で表現できるものはコメントに書かない:
        - How (どう動くか) はコード自体で表現する。処理・変数名・関数名を言い換えただけの説明をコメントに書かない。
        - What (何をするか、仕様) はテストコードで表現する。仕様の説明をコメントに書かない。
        - Why (なぜこの変更をしたか) はコミットメッセージで表現する。変更の経緯や理由をコメントに書かない。
        - Why not (なぜ別のやり方を採らなかったか、なぜあえてこう書いたか) だけがコードコメントの担当。
      - したがってコードコメントに書いてよいのは、原則として Why not と、コードから読み取れない非自明な事実 (単位・不変条件・並行性の前提・外部仕様や issue への参照など) に限る。それ以外は書かない。
      - 書く場合はなるべく短く、1 文・1 行で要点を締めること。複数節のだらだらした説明を書かない。平易で短い文にし、難しい語彙や凝った言い回しを避ける。例: 「Buffer is an append-only log buffer. It implements io.Writer (the build backend writes to it) and lets readers wait for new bytes from an offset until the buffer is closed.」ではなく「Buffer is an append-only log buffer implementing io.Writer; readers wait for new bytes from an offset until it is closed.」程度まで凝縮する。
      - コメント量は周囲の既存コードの密度に合わせ、そこから増やさないこと。既存コードを触るときは、周辺の冗長・自明なコメントも同じ基準で削り、増やす方向でなく減らす方向に整える。
      - 自分の作業ログ・変更履歴・TODO・AI が書いた旨を示すコメントを残さないこと。変更の経緯は git とコミットメッセージに委ねる。
    '';
    mcpServers = {
      thunderbird-mail = {
        command = "${pkgs.thunderbird-mcp}/bin/thunderbird-mcp";
      };
    };
    skills = {
      init-flake = ./skills/init-flake;
      natural-writing = ./skills/natural-writing;
      paper-writing = ./skills/paper-writing;
      writing-tech-article = ./skills/writing-tech-article;
      android-control = ./skills/android-control;
      writing-go = ./skills/writing-go;
      writing-ts = ./skills/writing-ts;
      writing-next = ./skills/writing-next;
      writing-kotlin = ./skills/writing-kotlin;
      writing-rust = ./skills/writing-rust;
      writing-zig = ./skills/writing-zig;
      writing-nix = ./skills/writing-nix;
      writing-python = ./skills/writing-python;
      auditing-kernel = ./skills/auditing-kernel;
      auditing-c-memory = ./skills/auditing-c-memory;
      auditing-web-app = ./skills/auditing-web-app;
    };
    agents = {
      # Weizhena/Deep-Research-skills
      web-search-agent = ./agents/web-search-agent.md;
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

  xdg.configFile."claude-code-proxy/config.json".text = builtins.toJSON {
    codex = {
      reasoningSummary = "off";
      reasoningSignatures = "off";
    };
  };

  home = {
    file.".claude/agents/web-search-modules" = {
      source = ./agents/web-search-modules;
      recursive = true;
    };

    # Codex owns config.toml at runtime (trust, model, notices), so seed a
    # writable copy instead of a read-only store symlink it cannot persist to.
    activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -L "$HOME/.codex/config.toml" ]; then
        run rm -f "$HOME/.codex/config.toml"
      fi
      if [ ! -e "$HOME/.codex/config.toml" ]; then
        run install -Dm600 ${codexConfig} "$HOME/.codex/config.toml"
      fi
    '';

    sessionVariables = {
      CLAUDE_CODE_NO_FLICKER = "1";
    };

    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.ccstatusline
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
      pkgs.gemini-cli
      pkgs.claude-code-proxy
      pkgs.claude-sol
    ];
  };
}
