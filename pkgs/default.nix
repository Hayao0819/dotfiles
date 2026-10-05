{ pkgs }:
let
  # Packages that require special arguments (e.g., kernel modules)
  # These are not exported as top-level packages
  excluded = [
    "default.nix"
    "intel-cvs" # Kernel module - requires kernel argument
  ];
in
builtins.readDir ./.
|> builtins.attrNames
|> builtins.filter (p: !builtins.elem p excluded)
|> builtins.map (p: {
  name = p;
  value = pkgs.callPackage (./. + "/${p}") { };
})
|> builtins.listToAttrs
