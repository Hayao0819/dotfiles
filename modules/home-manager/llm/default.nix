# LLM tools configuration module
# Includes Claude Code, Codex CLI, Gemini CLI, omp and Herdr
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  claudeSettingsPath = "${config.programs.claude-code.configDir}/settings.json";
  herdrPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
  claudeHerdrSessionHook = pkgs.writeShellScript "herdr-claude-session" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.python3
        pkgs.coreutils
      ]
    }:$PATH"
    exec ${pkgs.runtimeShell} ${herdrPackage}/share/herdr/integrations/claude/herdr-agent-state.sh session
  '';
  rule = name: builtins.readFile ./rules/${name}.md;
  joinRules = names: lib.concatStringsSep "\n" (map rule names);
  claudeRules = joinRules [
    "commit"
    "web-search"
    "safety"
    "chat-history"
    "natural-writing"
    "investigation"
    "subagent-models"
    "code-comments"
  ];
  portableRules = joinRules [
    "commit"
    "web-search"
    "safety"
    "code-comments"
  ];

  guardPatterns = builtins.fromJSON (builtins.readFile ./guard/patterns.json);
  externalWriteCommands = guardPatterns.gh_writes;
  externalWriteLines = lib.concatLists (
    lib.mapAttrsToList (group: verbs: map (verb: "gh ${group} ${verb}") verbs) externalWriteCommands
  );
  ghApiWriteGlobs = [
    "*gh api*-X *"
    "*gh api*--method*"
    "*gh api* -f *"
    "*gh api* -F *"
    "*gh api*--field*"
    "*gh api*--raw-field*"
    "*gh api*--input*"
  ];

  ompGuardGlobs = [ "*git*push*" ] ++ map (line: "*${line}*") externalWriteLines ++ ghApiWriteGlobs;
  guardData = pkgs.writeText "external-writes.json" (
    builtins.toJSON (guardPatterns // { ompGlobs = ompGuardGlobs; })
  );
  guardTools =
    pkgs.runCommand "external-writes-guard"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.nodejs
        ];
      }
      ''
        cp ${./guard}/*.py ${./guard}/*.json ${./guard}/*.mjs ${./guard}/*.ts .
        python -B -m unittest -v test_external_writes
        node test_omp_external_writes.mjs
        install -Dm644 external_writes.py $out/external_writes.py
      '';
  guardCommand =
    mode: "${pkgs.python3}/bin/python3 ${guardTools}/external_writes.py ${mode} ${guardData}";

  mergePython = pkgs.python3.withPackages (ps: [
    ps.tomlkit
    ps.pyyaml
  ]);
  mergeSettings = pkgs.runCommand "llm-merge-settings" { nativeBuildInputs = [ mergePython ]; } ''
    cp ${./merge_settings.py} merge_settings.py
    cp ${./test_merge_settings.py} test_merge_settings.py
    python -B -m unittest -v test_merge_settings
    install -Dm644 merge_settings.py $out/merge_settings.py
  '';
  mergeSettingsCommand = "${mergePython}/bin/python ${mergeSettings}/merge_settings.py";

  claudeMcpPlugin = pkgs.runCommand "claude-code-hm-plugin" { } ''
    install -Dm644 ${jsonFormat.generate "claude-code-plugin.json" { name = "hm"; }} \
      $out/.claude-plugin/plugin.json
    install -Dm644 ${
      jsonFormat.generate "claude-code-mcp.json" {
        mcpServers = {
          thunderbird-mail = {
            command = "${pkgs.thunderbird-mcp}/bin/thunderbird-mcp";
            type = "stdio";
          };
        };
      }
    } $out/.mcp.json
  '';

  ompConfig = jsonFormat.generate "omp-settings.json" {
    bash.patterns = map (match: {
      inherit match;
      approval = "prompt";
    }) ompGuardGlobs;
  };

  codexSafetyRules =
    let
      quote = s: ''"${s}"'';
      list = items: "[" + lib.concatStringsSep ", " (map quote items) + "]";
      rule = pattern: example: ''
        prefix_rule(
            pattern = ${pattern},
            decision = "prompt",
            justification = "External writes need explicit user approval",
            match = [${example}],
        )
      '';
    in
    rule
      (list [
        "git"
        "push"
      ])
      (list [
        "git"
        "push"
        "origin"
        "main"
      ])
    + lib.concatStrings (
      lib.mapAttrsToList (
        group: verbs:
        rule ("[" + quote "gh" + ", " + quote group + ", " + list verbs + "]") (list [
          "gh"
          group
          (lib.head verbs)
        ])
      ) externalWriteCommands
    );

  codexConfig = jsonFormat.generate "codex-settings.json" {
    hooks.PreToolUse = [
      {
        matcher = "^Bash$";
        hooks = [
          {
            type = "command";
            command = guardCommand "codex";
            timeout = 10;
            statusMessage = "Checking external writes";
          }
        ];
      }
    ];
    approval_policy = "on-request";
    sandbox_mode = "danger-full-access";
    features.daemon_auto_start = false;
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
      env.CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION = "600";
      hooks.PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = guardCommand "claude";
              timeout = 10;
              onFailure = "block";
            }
          ];
        }
      ];
      hooks.SessionStart = [
        {
          matcher = "^(startup|resume|clear|compact|fork)$";
          hooks = [
            {
              type = "command";
              command = "${claudeHerdrSessionHook}";
              timeout = 10;
            }
          ];
        }
      ];
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
        ask = [
          "Bash(git push *)"
        ]
        ++ map (line: "Bash(${line} *)") externalWriteLines;
      };
    };
    context = claudeRules;
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

  # Not programs.claude-code.mcpServers: home-manager 26.05 then wraps claude with
  # --plugin-dir, which `claude rc` rejects (home-manager#9618, fixed on master by
  # #9626). A skills-dir plugin is what that fix ships instead.
  home.file.".claude/skills/claude-code-home-manager".source = claudeMcpPlugin;

  # Home Manager 26.05 predates mutableSettings; keep its generated settings
  # source while replacing only the immutable runtime settings link.
  home.file."${claudeSettingsPath}".enable = false;

  # ccstatusline configuration
  xdg.configFile."ccstatusline/settings.json" = {
    force = true;
    text = builtins.toJSON {
      version = 4;
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
      flexMode = "full";
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
  };

  xdg.configFile."claude-code-proxy/config.json".text = builtins.toJSON {
    codex = {
      reasoningSummary = "off";
      reasoningSignatures = "off";
    };
  };

  home = {
    file.".codex/AGENTS.md".text = portableRules;
    file.".codex/rules/nix-safety.rules".text = codexSafetyRules;
    file.".omp/agent/AGENTS.md".text = portableRules;
    file.".omp/agent/hooks/pre/external-writes.ts".text =
      builtins.replaceStrings [ "@GUARD_DATA@" ] [ "${guardData}" ]
        (builtins.readFile ./guard/omp-external-writes.ts);

    file.".claude/agents/web-search-modules" = {
      source = ./agents/web-search-modules;
      recursive = true;
    };

    activation.llmSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run ${mergeSettingsCommand} json \
        ${config.home.file."${claudeSettingsPath}".source} \
        ${lib.escapeShellArg claudeSettingsPath}
      run ${mergeSettingsCommand} toml ${codexConfig} \
        ${lib.escapeShellArg "${config.home.homeDirectory}/.codex/config.toml"}
      run ${mergeSettingsCommand} yaml ${ompConfig} \
        ${lib.escapeShellArg "${config.home.homeDirectory}/.omp/agent/config.yml"}
    '';

    sessionVariables = {
      CLAUDE_CODE_NO_FLICKER = "1";
    };

    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.ccstatusline
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
      herdrPackage
      pkgs.gemini-cli
      pkgs.claude-code-proxy
      pkgs.claude-sol
    ];
  };
}
