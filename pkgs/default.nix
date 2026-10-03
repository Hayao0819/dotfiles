{ pkgs }:
let
  # Packages that require special arguments (e.g., kernel modules)
  # These are not exported as top-level packages
  excluded = [
    "default.nix"
    "intel-cvs" # Kernel module - requires kernel argument
  ];
  names = builtins.attrNames (builtins.readDir ./.);
  filtered = builtins.filter (p: !builtins.elem p excluded) names;
  packages = builtins.map (p: {
    name = p;
    value = pkgs.callPackage (./. + "/${p}") { };
  }) filtered;
in
builtins.listToAttrs packages
