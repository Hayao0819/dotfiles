# Cloudflared tunnel container
# Cloudflare Tunnelを通じてローカルサービスを外部に公開
{
  pkgs,
  lib,
  ...
}:
pkgs.dockerTools.buildLayeredImage {
  name = "cloudflared";
  tag = "latest";
  created = "now";

  contents = with pkgs; [
    # cloudflared本体
    cloudflared

    # SSL証明書
    cacert

    # デバッグ用（本番では削除可能）
    busybox
  ];

  # fakeRootCommandsで権限設定
  fakeRootCommands = ''
    mkdir -p ./etc/cloudflared
    mkdir -p ./home/nonroot/.cloudflared

    # cloudflared用の非rootユーザー設定
    echo "nonroot:x:65532:65532:nonroot:/home/nonroot:/bin/sh" >> ./etc/passwd
    echo "nonroot:x:65532:" >> ./etc/group
    chown -R 65532:65532 ./home/nonroot
  '';

  config = {
    # デフォルトはtunnelモード
    # 使用時: docker run ... cloudflared tunnel run --token <TOKEN>
    Entrypoint = [ "${pkgs.cloudflared}/bin/cloudflared" ];
    Cmd = [
      "tunnel"
      "--no-autoupdate"
      "run"
    ];

    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];

    # ヘルスチェック用のメトリクスポート
    ExposedPorts = {
      "2000/tcp" = { };
    };

    Volumes = {
      "/etc/cloudflared" = { };
      "/home/nonroot/.cloudflared" = { };
    };

    User = "65532:65532";

    Labels = {
      "org.opencontainers.image.source" = "https://github.com/Hayao0819/dotfiles";
      "org.opencontainers.image.description" = "Cloudflare Tunnel client";
      "org.opencontainers.image.licenses" = "MIT";
    };
  };
}
