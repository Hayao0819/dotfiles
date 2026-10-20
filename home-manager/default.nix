{
  inputs,
  outputs,
  ...
}:
let
  mkHomeConfig =
    { system, modules }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs { inherit system; };
      extraSpecialArgs = { inherit inputs outputs; };
      inherit modules;
    };
in
{
  "asahilinux" = mkHomeConfig {
    system = "aarch64-linux";
    modules = [
      ./asahilinux
    ];
  };

  "archlinux" = mkHomeConfig {
    system = "x86_64-linux";
    modules = [
      ./archlinux
    ];
  };

  "wsl" = mkHomeConfig {
    system = "x86_64-linux";
    modules = [
      ./wsl
    ];
  };

  "debian" = mkHomeConfig {
    system = "x86_64-linux";
    modules = [
      ./debian
    ];
  };
}
