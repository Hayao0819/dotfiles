# Caddy reverse proxy container
# URLでローカルIPを切り分けるシンプルなリバースプロキシ
{
  pkgs,
  lib,
  ...
}:
let
  # 設定ファイルをNixで生成
  caddyfile = pkgs.writeText "Caddyfile" ''
    # グローバル設定
    {
      # 管理API（コンテナ内からの設定変更用）
      admin off
      # ログ設定
      log {
        output stdout
        format console
      }
    }

    # 設定例: ローカルサービスへのリバースプロキシ
    # 実際の使用時は環境変数やボリュームマウントで設定を上書き
    :80 {
      respond "Caddy reverse proxy is running"
    }
  '';
in
pkgs.dockerTools.buildLayeredImage {
  name = "caddy-proxy";
  tag = "latest";
  created = "now";

  contents = with pkgs; [
    # Caddy本体
    caddy

    # SSL証明書
    cacert

    # デバッグ用（本番では削除可能）
    busybox
  ];

  # fakeRootCommandsで権限設定
  fakeRootCommands = ''
    mkdir -p ./etc/caddy
    mkdir -p ./data/caddy
    mkdir -p ./config/caddy

    # Caddyfile をコピー
    cp ${caddyfile} ./etc/caddy/Caddyfile
  '';

  config = {
    Cmd = [
      "${pkgs.caddy}/bin/caddy"
      "run"
      "--config"
      "/etc/caddy/Caddyfile"
      "--adapter"
      "caddyfile"
    ];

    ExposedPorts = {
      "80/tcp" = { };
      "443/tcp" = { };
    };

    Env = [
      "XDG_CONFIG_HOME=/config"
      "XDG_DATA_HOME=/data"
    ];

    Volumes = {
      "/etc/caddy" = { };
      "/data/caddy" = { };
      "/config/caddy" = { };
    };

    Labels = {
      "org.opencontainers.image.source" = "https://github.com/Hayao0819/dotfiles";
      "org.opencontainers.image.description" = "Caddy reverse proxy for local services";
      "org.opencontainers.image.licenses" = "MIT";
    };
  };
}
