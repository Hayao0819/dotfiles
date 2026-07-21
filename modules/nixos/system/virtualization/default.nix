{ pkgs, ... }:

{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
      enableKvm = true;
      addNetworkInterface = false;
    };

    docker.enable = true;
  };

  services.spice-vdagentd.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    virtiofsd
    qemu-utils
    lxc
    docker-compose
    docker-buildx
  ];

  programs.dconf.enable = true;
}
