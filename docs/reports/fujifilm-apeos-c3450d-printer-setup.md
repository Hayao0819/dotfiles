# Fujifilm Apeos C3450d プリンタードライバー NixOS セットアップレポート

**作成日:** 2026-02-13

## 概要

Fujifilm Apeos C3450d カラー複合機を NixOS で使用するためのドライバー調査と設定を行った。

## プリンター情報

| 項目 | 内容 |
|------|------|
| メーカー | FUJIFILM Business Innovation（旧Fuji Xerox） |
| モデル | Apeos C3450d |
| 種類 | カラー複合機 |
| 公式サポート | Linux対応あり |

## 公式Linuxドライバー

### ドライバー情報

| 形式 | ファイル名 | バージョン | 対応OS |
|------|-----------|-----------|--------|
| RPM | `fflinuxprint-1.1.4-1.x86_64.rpm` | 1.1.4-1 | RHEL 9/10 |
| DEB | `fflinuxprint_1.1.4-3_amd64.deb` | 1.1.4-3 | Ubuntu 22.04/24.04 |

### 公式ダウンロードURL

- RPM: https://www.fujifilm.com/fb/sync/pub/exe/2025/fflinuxprint-1.1.4-1.x86_64.rpm
- DEB: https://www.fujifilm.com/fb/sync/pub/exe/docuprint/p450d/fflinuxprint_1.1.4-3_amd64.deb

### ダウンロードページ

- https://www.fujifilm.com/fb/download/apeosport/1860/linux/nb_linux64 (RPM)
- https://www.fujifilm.com/fb/download/apeosport/1860/linux/nb_linux_ubun64 (DEB)

### 対応機種

100機種以上のApeosPort、DocuCentre、DocuPrintシリーズに対応：

- ApeosPort 1860, 2560, 3060, C3450d など
- DocuCentre シリーズ
- DocuPrint シリーズ

## NixOS での対応状況

### nixpkgs パッケージ

nixpkgsに `fflinuxprint` パッケージが既に存在する。

```bash
$ nix search nixpkgs fflinuxprint
* legacyPackages.x86_64-linux.fflinuxprint (1.1.3-4)
  FujiFILM Linux Printer Driver
```

| 項目 | 内容 |
|------|------|
| パッケージ名 | `fflinuxprint` |
| nixpkgsバージョン | 1.1.3-4 |
| 最新公式バージョン | 1.1.4-3 (DEB) / 1.1.4-1 (RPM) |
| ライセンス | unfree |
| ソース | `/pkgs/by-name/ff/fflinuxprint/package.nix` |
| ホームページ | https://support-fb.fujifilm.com |
| メンテナー | James Duff (@jaduff) |

### 注意事項

- `unfree` ライセンスのため、`nixpkgs.config.allowUnfree = true` が必要
- nixpkgsのバージョン (1.1.3-4) は公式最新版 (1.1.4-x) より古い

## 実装内容

### 設定ファイル

**`modules/nixos/system/printing/default.nix`**

```nix
# Printing configuration with Fujifilm Apeos C3450d support
# Uses fflinuxprint (official Fujifilm Linux driver) for ApeosPort/DocuCentre/DocuPrint series
{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      # Fujifilm official Linux driver for Apeos C3450d and other ApeosPort/DocuCentre series
      # https://www.fujifilm.com/fb/download/apeosport/1860/linux/nb_linux64
      fflinuxprint
      # CUPS filters for network printer discovery
      cups-filters
    ];
  };

  # Enable network printer auto-discovery via Avahi/mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
```

### 関連ファイル

| ファイル | 変更内容 |
|---------|---------|
| `modules/nixos/system/printing/default.nix` | 新規作成 (fflinuxprint使用) |
| `modules/nixos/system/default.nix` | printing モジュール追加 |
| `modules/nixos/system/common/default.nix` | 重複する printing 設定削除 |
| `nixos/xps9350/configuration.nix` | printing モジュール import 追加 |

## 使用方法

### 1. NixOS 再ビルド

```bash
sudo nixos-rebuild switch --flake .
```

### 2. プリンター追加

CUPS Web インターフェース（http://localhost:631）でプリンターを追加：

1. **Administration** → **Add Printer**
2. ネットワークプリンターを選択（自動検出またはIP指定）
   - LPD: `lpd://プリンターIP`
   - Socket: `socket://プリンターIP:9100`
   - IPP: `ipp://プリンターIP/ipp/print`
3. ドライバー選択: **Fujifilm** → **fflinuxprint**

### 3. コマンドラインでの確認

```bash
# 利用可能なドライバー確認
lpinfo -m | grep -i fuji

# プリンター一覧
lpstat -p -d
```

## トラブルシューティング

### unfreeパッケージのエラー

`fflinuxprint` は unfree パッケージのため、以下の設定が必要：

```nix
nixpkgs.config.allowUnfree = true;
```

### プリンターが検出されない場合

```bash
# Avahi サービス確認
systemctl status avahi-daemon

# ネットワーク上のプリンター検索
avahi-browse -a | grep -i print
lpinfo -v
```

### 印刷できない場合

```bash
# CUPS ログ確認
journalctl -u cups -f

# ジョブ状態確認
lpstat -t
```

## 参考リンク

### 公式ドキュメント

- [Fujifilm ドライバーダウンロード](https://www.fujifilm.com/fb/download)
- [Fujifilm サポート](https://support-fb.fujifilm.com)

### NixOS関連

- [NixOS Printing Wiki](https://wiki.nixos.org/wiki/Printing)
- [nixpkgs fflinuxprint](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ff/fflinuxprint/package.nix)

### コミュニティ

- [KYchem - Installing Fuji Xerox ApeosPort printer in Linux](https://kychem.wordpress.com/2024/12/05/installing-fuju-xerox-apeosport-c2560-printer-in-linux/)
- [AUR xerox-docucentre-driver](https://aur.archlinux.org/packages/xerox-docucentre-driver)

## 既知の制限事項

1. **バージョン差異**: nixpkgsのfflinuxprint (1.1.3-4) は公式最新版 (1.1.4-x) より古い
2. **両面印刷**: OSやアプリケーションの設定によっては、奇数ページ印刷時に空白ページが追加される場合がある
3. **unfreeライセンス**: 再配布不可のため、allowUnfree設定が必須
