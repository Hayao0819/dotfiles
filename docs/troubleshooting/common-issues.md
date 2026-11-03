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

## GitHub Actions のランナー停止

[PR #23 の実行](https://github.com/Hayao0819/dotfiles/actions/runs/40265374917)では
flake check は成功し、XPS9350 の全体ビルドがランナーの shutdown signal・終了コード 143 で停止しました。
取得予定は 11.9 GiB、展開後 33.7 GiB で、別途 1597 個の derivation のビルドも必要でした。
[コメント](https://github.com/Hayao0819/dotfiles/pull/23#issuecomment-6437782207)では容量不足が指摘されていますが、
取得できたログに `No space left on device` や OOM の明示はありません。
[展開後 30.5 GiB の成功例](https://github.com/Hayao0819/dotfiles/actions/runs/39449845065)もあるため、
終了コードだけで容量不足と断定せず、ビルド開始前と実行中の `df -h / /nix`・`df -i / /nix`・`free -h` を記録します。

当該実行の取得元は `cache.nixos.org` のみで、Codex・Herdr もソースビルドしていました。
`llm-agents` を入力として使う場合、提供元のキャッシュは利用側でも明示的な設定が必要です。
PR #23 と同じ Codex 0.164.0・Herdr 0.9.5 の出力は、提供元の署名付きキャッシュに存在します。
CI と同じ設定で `--max-jobs 0` を指定し、ソースビルドを禁止した取得も成功しました。

`.github/workflows/test-flake.yml` は全体ビルドを維持して次の対策を行います。

- Nix のインストール時に Numtide の `extra-substituters` と `extra-trusted-public-keys` を設定します。
- GitHub-hosted Linux ランナーから不要な Android・.NET・Haskell・ツールキャッシュを削除し、前後の空き容量を記録します。
- `max-jobs = 1` と `cores = 2` でビルドの並列度を制限します。メモリ使用量の上限ではありません。
- `--no-fallback` で、キャッシュ取得失敗から LLVM・Rust などのソースビルドへの切り替えを防ぎます。
- `.github/scripts/nix-build.sh` でビルドログと毎分のディスク・メモリ使用量を記録します。
  Linux では inode と RSS の大きいプロセス、macOS では `vm_stat` も記録します。
  スクリプトは終了コードを保持し、終了時に監視プロセスを停止します。

XPS9350 は `gpgui-free` のモジュールが GlobalProtect-openconnect 2.5.4 のバックエンドもビルドします。
ログの `rust-workspace-2.5.4` はこのバックエンドで、Codex のキャッシュだけでは全ソースビルドを省略できません。
CPU・メモリ負荷は [Nix の並列度設定](https://nix.dev/manual/nix/2.31/command-ref/conf-file.html#conf-max-jobs)も参照してください。

CI を flake check のみに変更すると、全体ビルドの検証は省略されます。
検証範囲は [Nix の仕様](https://nix.dev/manual/nix/2.31/command-ref/new-cli/nix3-flake-check.html)を参照してください。

[2026-10-23 の WSL の失敗](https://github.com/Hayao0819/dotfiles/actions/runs/39891425275/job/120211843231)は、
`cache.nixos.org` からの取得再開時の HTTP 416 と、その後の依存パッケージ取得失敗でした。
当時の `--fallback` により LLVM・Rust までソースビルドへ切り替わり、依存ビルドが連鎖して失敗しています。
`--no-fallback` は通信障害そのものを修復する設定ではありません。再実行時にキャッシュ取得が成功するか確認します。
ランナー停止とは分けて調べます。PR #23 の WSL ビルドは成功しています。

## LLM 設定の書き込み失敗

`modules/home-manager/llm/` は Claude と Codex の設定を適用時に書き込み可能なファイルへマージします。
宣言した値は既存値に優先し、リストは置換します。宣言から削除した値は実ファイルから自動削除されません。
既存の JSON / TOML が不正な場合は修正してから再適用してください。

指示ファイルとスキルは Nix store へのリンクです。編集はリポジトリ側で行い、再適用します。

## Codex の `bwrap: setting up uid map: Permission denied`

Codex の Linux サンドボックスは [bwrap と seccomp](https://learn.chatgpt.com/docs/agent-approvals-security#os-level-sandbox)を使用します。
このエラーは実行対象のコマンドを起動する前に、bubblewrap が `/proc/<pid>/uid_map` を開くか書き込む段階で発生します。
Codex 0.163.0 の実装でも、ユーザー名前空間が利用できない場合のエラーとして扱われています。
メッセージだけでは拒否した仕組みを確定できないため、対象マシンで次を確認します。

```bash
codex --version
codex sandbox --help
command -v bwrap
unshare -Ur /usr/bin/true
bwrap --unshare-user --ro-bind / / -- /usr/bin/id
codex sandbox --permission-profile :workspace -- /usr/bin/true
```

最後のコマンドは Codex 0.163.0 の CLI 形式です。インストール済みバージョンのヘルプを優先してください。
Codex は PATH 上の bwrap を優先し、見つからない場合は同梱版を使用します。両方を比較して切り分けます。
`kernel.unprivileged_userns_clone`・`user.max_user_namespaces`、AppArmor、コンテナーの権限制限、
`/proc/self/uid_map`・`/proc/self/gid_map` を確認し、必要なら bwrap 単体を strace して拒否されたシステムコールを特定します。
Home Manager の switch だけでは、ホストのカーネル設定や AppArmor ポリシーは変更されません。

通常起動時の動作は、実際の `~/.codex/config.toml`、選択したプロファイル、起動オプション、
プロジェクト設定も確認します。`workspace-write` と `danger-full-access` はサンドボックスの扱いが異なります。
宣言元の設定と実機の設定を照合してから、対処する設定を決めてください。

### Ubuntu 26.04 の AppArmor による拒否

`debian` は Home Manager のプロファイル名なので、実際の OS は `/etc/os-release` で確認します。
Ubuntu 26.04.1・AppArmor 5.0.2・Codex 0.163.0 の環境で、次の状態を確認しています。

- `kernel.unprivileged_userns_clone = 1`、`user.max_user_namespaces` も 0 より大きい。
- `kernel.apparmor_restrict_unprivileged_userns = 1` と `kernel.apparmor_restrict_unprivileged_unconfined = 1`。
- OS の `bubblewrap` は未導入で、Codex は Nix store の同梱版を使用している。
- `journalctl -k` に `profile="unprivileged_userns"`、`operation="open"`、`name="proc/<pid>/uid_map"`、`error=-13` が記録される。
  `setpcap`・`net_admin` の拒否も記録され、Codex のテストでは loopback 設定の失敗になる場合もある。

この場合は AppArmor の監査ログで原因を確認できます。同一ハッシュの Nix 版 bwrap は Debian 13 で動作しており、
対象環境では通常の bwrap 実行と `workspace` サンドボックスが失敗し、`danger-full-access` の対照テストは成功しました。

Ubuntu の `/etc/apparmor.d/bwrap-userns-restrict` は `profile bwrap /usr/bin/bwrap` に適用されます。
Nix store の bwrap にはこのパスのプロファイルが適用されないため、
[OpenAI の前提条件](https://learn.chatgpt.com/docs/sandboxing#prerequisites)に従い OS のパッケージを導入します。
APT のシミュレーションでは `bubblewrap` 1 個の追加で、他のパッケージの変更はありませんでした。
以下の導入操作には sudo 認証が必要です。サンドボックスを維持した修復の推奨手順であり、実機での導入後検証は別途必要です。

```bash
sudo apt install bubblewrap
command -v bwrap
readlink -f "$(command -v bwrap)"
bwrap --unshare-user --ro-bind / / -- /usr/bin/id
codex sandbox --permission-profile :workspace -- /usr/bin/true
```

`/usr/bin/bwrap` が選択されることと、最後の 2 コマンドの終了コードが 0 であることを確認します。
Ubuntu 26.04 では `aa-exec -p bwrap` だけで Nix 版を起動しても、
`change_profile unprivileged unconfined converted to stacking` と記録され、同じ UID map エラーが再現しました。

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
