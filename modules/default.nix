{
  # Reusable nixos modules you might want to export
  # These are usually stuff you would upstream into nixpkgs
  nixos = import ./nixos;

  # Reusable home-manager modules you might want to export
  # These are usually stuff you would upstream into home-manager
  home = import ./home-manager;

  # Reusable darwin modules you might want to export
  # These are usually stuff you would upstream into nixpkgs
  darwin = import ./darwin;
}
