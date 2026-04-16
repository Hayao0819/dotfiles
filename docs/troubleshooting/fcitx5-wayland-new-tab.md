# Fcitx5: 新規タブで日本語入力が機能しない問題

## ステータス: 未修正 (調査済み)

## 現象

GNOME Wayland 環境で、Fcitx5 + Mozc による日本語入力が特定のアプリケーションの新規タブ/コンテキストで機能しない。

### 再現手順

1. GNOME Console (kgx) を開く
2. 日本語入力切り替えのショートカットキーを押す → **切り替わらない**
3. Fcitx5 の「設定をリロード」をクリック → 現在のタブで動作するようになる
4. 新しいタブを開く → **そのタブでのみ**日本語入力切り替えが機能しない
5. 再度「設定をリロード」をクリック → そのタブでも動作するようになる

### 影響を受けるアプリケーション

- GNOME Console (kgx) — GTK4 + VTE
- ブラウザ版 LINE (Chrome/Firefox 内)

### 影響を受ける環境

- Arch Linux + GNOME Wayland
- NixOS + GNOME Wayland
- OS に依存しない (GNOME + Fcitx5 の構造的問題)

## 原因分析

### 根本原因: `GTK_IM_MODULE=fcitx` のグローバル設定

`GTK_IM_MODULE=fcitx` が設定されていると、GTK4 アプリは Mutter のフォーカス管理をバイパスして fcitx5 の GTK IM モジュールと直接通信する。この直接通信パスで、新規タブ (= 新規 InputContext) の初期化時にレースコンディションまたはフォーカスイベントの欠落が発生する。

```
[問題のあるデータフロー] (GTK_IM_MODULE=fcitx 設定時)
GTK4アプリ → fcitx5 GTK IMモジュール → DBus → fcitx5デーモン
               └─ Mutterのフォーカス管理をバイパス
               └─ 新規InputContextの初期化でレースコンディション

[正常なデータフロー] (GTK_IM_MODULE 未設定時)
GTK4アプリ → text-input-v3 → Mutter → ibus DBus → fcitx5デーモン
                                └─ Mutterが全surfaceのフォーカスを正しく管理
```

### 診断結果の証拠 (`fcitx5-diagnose`)

```
# kgx の InputContext が frontend:dbus (ibus プロトコル経由)
IC [f18a...] program:kgx frontend:dbus cap:4001000032 focus:1
IC [ae7c...] program:kgx frontend:dbus cap:4001000032 focus:0
...
# 名前のない ibus IC も存在 (GNOME 自体の ibus 統合との二重管理)
IC [79fe...] program: frontend:ibus cap:52 focus:0
```

### Fcitx5 公式の推奨設定

[Using Fcitx 5 on Wayland](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland) より:

> "Do NOT set GTK_IM_MODULE environment variable"

GNOME でも wlroots 系 (Hyprland/Sway) でも、GTK4 アプリは native の text-input-v3 を使うべきとされている。

## 修正方法

### NixOS: `waylandFrontend = true` を設定

nixpkgs の fcitx5 モジュール (`nixos/modules/i18n/input-method/fcitx5.nix`) に `waylandFrontend` オプションが存在する。有効にすると `GTK_IM_MODULE` と `QT_IM_MODULE` が設定されなくなる。

```nix
# modules/nixos/user/fcitx5/default.nix
{ pkgs, ... }:
{
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = [ pkgs.fcitx5-mozc-ut ];
    fcitx5.waylandFrontend = true;  # ← 追加
  };
}
```

**影響:**

- `GTK_IM_MODULE` が設定されなくなる → GTK4 アプリは text-input-v3 を使用
- `QT_IM_MODULE` も設定されなくなる → Qt6.7+ は text-input-v3 を native サポート
- `XMODIFIERS=@im=fcitx` は引き続き設定される
- GNOME: Mutter → ibus DBus → fcitx5 の正規パスで動作
- Hyprland: Hyprland → input-method-v2 → fcitx5 の正規パスで動作

### Arch Linux: `/etc/environment` から `GTK_IM_MODULE` を削除

```diff
# /etc/environment
-GTK_IM_MODULE=fcitx
 QT_IM_MODULE=fcitx
 XMODIFIERS="@im=fcitx"
```

GTK3 の X11/XWayland アプリ用には設定ファイルで個別指定:

```ini
# ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-im-module=fcitx
```

### 注意事項

- 変更後は GNOME セッションへの再ログインが必要
- 古い Qt5 アプリで入力メソッドが動作しなくなった場合は `QT_IM_MODULE=fcitx` を別途設定
- XWayland アプリ (一部の Electron アプリ等) では個別に `GTK_IM_MODULE=fcitx` が必要な場合がある

## 上流の関連 Issue

| Issue | 概要 |
|---|---|
| [NixOS/nixpkgs#270432](https://github.com/NixOS/nixpkgs/issues/270432) | Wayland 上で fcitx5 が `*_IM_MODULE` 環境変数を設定すべきでない → `waylandFrontend` オプション追加で解決 |
| [ibus/ibus#2638](https://github.com/ibus/ibus/issues/2638) | GTK4 popover で ibus 入力切替不可 → Mutter の grab 変更バグが原因 |
| [fcitx/fcitx5#1218](https://github.com/fcitx/fcitx5/issues/1218) | Ghostty (GTK4) で `GTK_IM_MODULE=fcitx` だとアクティベート不可 |
| [ghostty-org/ghostty#4332](https://github.com/ghostty-org/ghostty/issues/4332) | Ghostty の入力メソッドハンドリングを Wayland/X11 対応に根本的に作り直し |
| [fcitx/fcitx5#333](https://github.com/fcitx/fcitx5/issues/333) | Wayland でグローバルホットキーの標準がなく、入力コントロールにフォーカスしないとトリガーできない (仕様) |
| [Red Hat BZ#2054680](https://bugzilla.redhat.com/show_bug.cgi?id=2054680) | GTK4 が ibus-gtk4 を Wayland 入力プロトコルより優先する問題 → GTK4 側で修正済み |

## 参考資料

- [Using Fcitx 5 on Wayland - Fcitx Wiki](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland)
- [Fcitx5 - ArchWiki](https://wiki.archlinux.org/title/Fcitx5)
- [Setup Fcitx 5 - Fcitx Wiki](https://fcitx-im.org/wiki/Setup_Fcitx_5)

## 調査日

2026-03-18
