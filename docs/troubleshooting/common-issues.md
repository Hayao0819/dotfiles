# トラブルシューティング

## 評価・ビルドの失敗

[検証コマンド](../setup/validation.md) に `--show-trace` を付けて原因を確認します。
存在しない属性は出力名・import・パッケージ名を確認してください。
新規ファイルが Git 未追跡の場合は、ローカルの参照を `path:.` にします。

## ビルド中のメモリ不足

`--max-jobs 1 --cores 1` で同時ビルド数と各ビルドの並列度を制限します。
これはメモリ使用量の上限ではありません。

LLM ツールは [提供元のバイナリキャッシュ](https://github.com/numtide/llm-agents.nix#binary-cache)
を利用するとソースビルドを減らせます。swap やメモリ制限はホスト OS 側で設定します。

## LLM 設定の書き込み失敗

`modules/home-manager/llm/` は Claude と Codex の設定を適用時に書き込み可能なファイルへマージします。
宣言した値は既存値に優先し、リストは置換します。宣言から削除した値は実ファイルから自動削除されません。
既存の JSON / TOML が不正な場合は修正してから再適用してください。

指示ファイルとスキルは Nix store へのリンクです。編集はリポジトリ側で行い、再適用します。

## 印刷

`modules/nixos/system/printing/` が CUPS・Avahi と Fujifilm 用の `fflinuxprint` を設定します。
適用後は [CUPS](http://localhost:631) でプリンターを追加してください。

```bash
lpinfo -v                 # 接続先
lpinfo -m                # ドライバー
lpstat -t                # キューとジョブ
journalctl -u cups -b     # エラーログ
```

日本語入力については [Fcitx5 の確認手順](fcitx5-wayland-new-tab.md) を参照してください。
