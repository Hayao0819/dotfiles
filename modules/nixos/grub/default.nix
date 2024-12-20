{ device ? "nodev", ... }:
{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = device;
  boot.loader.grub.useOSProber = true;
}
