# 変更後の検証

`direnv allow` または `nix develop` で開発ツールを読み込めます。
開発環境は `x86_64-linux` と `aarch64-linux` に対応しています。

ファイル変更後は treefmt、Nix ファイル変更後は flake check を実行します。

```bash
treefmt
nix flake check path:. --extra-experimental-features 'nix-command flakes pipe-operators'
git diff --check
```

現在の `treefmt.toml` は雛形で、実行できるフォーマッターが未設定です。
Nix ファイルの整形には `nixfmt` を使用できます。

flake check は実行環境と異なるアーキテクチャや独自の出力をすべてビルドするものではありません。
変更した適用先も明示してビルドしてください。以下は設定の適用を行いません。

```bash
# このマシンで利用するプロファイルを指定
nix build --no-link path:.#homeConfigurations.asahilinux.activationPackage \
  --extra-experimental-features 'nix-command flakes pipe-operators' \
  --max-jobs 1 --cores 1

# NixOS の場合は対応するビルド環境で実行
nix build --no-link path:.#nixosConfigurations.XPS9350.config.system.build.toplevel \
  --extra-experimental-features 'nix-command flakes pipe-operators'
```
