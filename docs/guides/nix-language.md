# Nix の編集

共通設定を追加するときは `modules/` の既存モジュールを参考にしてください。
条件付きのモジュール設定には `lib.mkIf`、既定値には `lib.mkDefault` を使用します。
このリポジトリの `|>` 構文には `pipe-operators` の有効化が必要です。

言語仕様は [Nix 公式マニュアル](https://nix.dev/manual/nix/latest/language/)、
変更後の確認方法は [検証手順](../setup/validation.md) を参照してください。
