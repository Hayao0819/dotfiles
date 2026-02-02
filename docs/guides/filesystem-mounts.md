# File System Mounts

## Basic Mount
```nix
fileSystems."/mnt/data" = {
  device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
  fsType = "ext4";  # or btrfs, ntfs, exfat
};
```

## Find UUIDs
```bash
lsblk -f
ls -la /dev/disk/by-uuid/
```

## Mount Options
```nix
fileSystems."/mnt/external" = {
  device = "/dev/disk/by-uuid/...";
  fsType = "btrfs";
  options = [
    "nofail"       # Don't fail boot if mount fails
    "users"        # Allow any user to mount/unmount
    "x-gvfs-show"  # Show in file managers
  ];
};
```

## Btrfs Subvolumes
```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/...";
  fsType = "btrfs";
  options = [ "subvol=@" ];
};

fileSystems."/home" = {
  device = "/dev/disk/by-uuid/...";  # Same device
  fsType = "btrfs";
  options = [ "subvol=@home" ];
};
```

## Important
- Always use `/dev/disk/by-uuid/` (topology-independent)
- Use `nofail` for optional/external drives
- Changes require `nixos-rebuild switch`