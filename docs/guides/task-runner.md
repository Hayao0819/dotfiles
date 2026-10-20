# タスクランナー

`tasks.nix` の補助コマンドです。`x86_64-linux` と `aarch64-linux` で利用できます。
macOS では [直接の適用コマンド](../reference/commands.md) を使用してください。

```bash
nix run . -- --nixos XPS9350 --action switch
nix run . -- --home debian
nix run .#update
nix run .#check
nix run .#status
nix run .#clean
```

引数なしの適用は NixOS のホスト名から設定を選びます。
standalone Home Manager の適用先は `--home` で指定します。
`clean` は 7 日より古い世代を削除して GC を実行するため、削除した世代には戻せません。
