# Wayland で日本語入力が動かない場合

Fcitx5 + Mozc の設定は `modules/nixos/user/fcitx5/default.nix` にあります。
特定のアプリや新規タブだけで入力できない場合は、まず次を確認します。

```bash
fcitx5-diagnose
printenv GTK_IM_MODULE QT_IM_MODULE XMODIFIERS
```

Wayland と XWayland では適切な環境変数が異なります。
`GTK_IM_MODULE` などを全アプリへ一律に設定する前に、
[Fcitx5 公式の Wayland 設定](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland)
でデスクトップとアプリに合う方法を確認してください。環境変数を変更した後は再ログインします。
