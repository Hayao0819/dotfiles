# Virtualization configuration for NixOS
# Migrated from Arch Linux (QEMU/KVM, libvirt, VirtualBox)
{ pkgs, ... }:

{
  # QEMU/KVM virtualization with libvirt
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;  # TPM emulation support
      # OVMF is included by default with QEMU in NixOS
    };
  };

  # VirtualBox
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;  # USB 2.0/3.0, VirtualBox RDP, etc.
  };

  # Spice agent for VM clipboard sharing and display optimization
  services.spice-vdagentd.enable = true;

  # Virtualization management tools
  environment.systemPackages = with pkgs; [
    # QEMU/KVM
    virt-manager      # GUI for libvirt
    virt-viewer       # VM display viewer
    virtiofsd         # VirtIO filesystem daemon for file sharing

    # Utilities
    qemu-utils        # QEMU disk image utilities (qemu-img, etc.)

    # Container tools (LXC)
    lxc               # Linux Containers
  ];

  # Enable dconf for virt-manager settings persistence
  programs.dconf.enable = true;
}
