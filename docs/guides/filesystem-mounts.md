# NixOS のマウント設定

対象マシンの設定に追加します。UUID は `lsblk -f` で確認してください。
既存のルート・ブート領域の定義は `hardware-configuration.nix` を参照します。

```nix
fileSystems."/mnt/data" = {
  device = "/dev/disk/by-uuid/<UUID>";
  fsType = "ext4";
  options = [ "nofail" ]; # 未接続でも起動する外付けディスク向け
};
```

変更後は [検証](../setup/validation.md) を行い、対象の NixOS 設定を適用します。
standalone Home Manager はシステムのマウントを管理しません。
