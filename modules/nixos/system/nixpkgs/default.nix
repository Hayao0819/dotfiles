{
  lib,
  config,
  inputs,
  outputs,
  ...
}:
{
  # Import common nixpkgs configuration
  imports = [
    outputs.modules.common.nixpkgs
  ];

  config = {

    nix = {
      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = config.nix.registry |> lib.mapAttrsToList (key: value: "${key}=${value.to.path}");

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes pipe-operators";
      };
    };
  };
}
