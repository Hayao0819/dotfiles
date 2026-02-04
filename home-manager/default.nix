{
  inputs,
  outputs,
  ...
}:
{
  "archlinux" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };

    extraSpecialArgs = { inherit inputs outputs; };
    modules = [
      ./linux
      ./archlinux
    ];
  };

  "linux" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };

    extraSpecialArgs = { inherit inputs outputs; };
    modules = [
      ./linux
    ];
  };
}
