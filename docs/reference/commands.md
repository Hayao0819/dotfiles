# 適用・更新

Nix の設定で `extra-experimental-features = nix-command flakes pipe-operators` を有効にし、
リポジトリのルートで実行します。sudo を使う操作ではシステム側の Nix 設定にも必要です。
未追跡の新規ファイルも読み込めるよう、ローカルの例では `path:.` を使います。

## Home Manager

初回は適用先の設定と既存ファイルを確認してください。
`before-hm` を付けたバックアップが既にある場合は別の名前を指定します。sudo は不要です。

```bash
# asahilinux を xps9350-arch / debian / wsl に置き換えて選択
home-manager switch --flake path:.#asahilinux -b before-hm
```

Home Manager 未導入の場合は、リポジトリと同じリリース系列の CLI を使えます。

```bash
nix run github:nix-community/home-manager/release-26.05 -- switch --flake path:.#asahilinux -b before-hm
```

## NixOS / macOS

XPS9350 の Home Manager は NixOS と一緒に適用します。

```bash
sudo nixos-rebuild switch --flake path:.#XPS9350
sudo nixos-rebuild boot --flake path:.#XPS9350  # 次回起動時に適用
sudo darwin-rebuild switch --flake path:.#MacBook
```

## 更新

```bash
nix flake update                 # 全入力を更新
nix flake update llm-agents      # LLM ツールの入力だけ更新
```

更新後は [検証](../setup/validation.md) を行ってから適用してください。
