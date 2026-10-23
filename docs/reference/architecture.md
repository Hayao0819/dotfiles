# 構成

## ディレクトリ

| パス | 内容 |
|---|---|
| `flake.nix` / `flake.lock` | 出力の定義と依存バージョン |
| `nixos/` | NixOS のマシン別設定 |
| `home-manager/` | standalone Home Manager の設定 |
| `darwin/` | nix-darwin の設定 |
| `nix-on-droid/` | Android のユーザー環境 |
| `modules/` | 共通・プラットフォーム別のモジュール |
| `pkgs/` / `overlays/` | 独自パッケージとパッケージの変更 |
| `tasks.nix` | 更新・適用などの補助コマンド |

## 適用先

| 出力 | 対象 |
|---|---|
| `nixosConfigurations.XPS9350` | NixOS。Home Manager は `nixos/XPS9350/home.nix` を統合 |
| `nixosConfigurations.WSL` / `Installer` | NixOS-WSL / インストーラー |
| `homeConfigurations.xps9350-arch` | x86_64 Linux の XPS 9350。テーマ・XDG 設定を含み dconf 管理を無効化 |
| `homeConfigurations.debian` | x86_64 Linux。シェル・開発ツール中心 |
| `homeConfigurations.asahilinux` | aarch64 Linux。Debian 設定を継承し dconf 管理を無効化 |
| `homeConfigurations.wsl` | x86_64 Linux。壁紙・テーマ・音声設定を除外 |
| `darwinConfigurations.MacBook` | Apple Silicon の macOS |
| `nixOnDroidConfigurations.termux` | Android |

standalone の設定は `hayao` / `/home/hayao` 用です。
`home-manager/darwin/` は standalone 出力として登録されていません。
Asahi のカーネル・ブートローダー・音声基盤はホスト OS で管理します。

## 設定の追加

共通モジュールは `modules/` の各 `default.nix` から自動検出されます。
新しい Home Manager 設定は `home-manager/<名前>/default.nix` を作り、
`home-manager/default.nix` に対象アーキテクチャと出力を登録してください。
NixOS のマシンは `nixos/<名前>/configuration.nix` で定義します。

適用方法は [コマンド一覧](commands.md)、変更後の確認は [検証手順](../setup/validation.md) を参照してください。
