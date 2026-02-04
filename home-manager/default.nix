{
  inputs,
  outputs,
  ...
}:
let
  mkHomeConfig = { system, modules }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { inherit system; };
    extraSpecialArgs = { inherit inputs outputs; };
    inherit modules;
  };
in
{
  "archlinux" = mkHomeConfig {
    system = "x86_64-linux";
    modules = [
      ./linux
      ./archlinux
    ];
  };

  "linux" = mkHomeConfig {
    system = "x86_64-linux";
    modules = [
      ./linux
    ];
  };
}
