{ ... }: {
  # Reusable nixos modules you might want to export
  # These are usually stuff you would upstream into nixpkgs
  nixos = import ./modules/nixos;

  # Reusable home-manager modules you might want to export
  # These are usually stuff you would upstream into home-manager
  home = import ./modules/home-manager;

  # Reusable darwin modules you might want to export
  # These are usually stuff you would upstream into nixpkgs
  darwin = import ./modules/darwin;
}
