{ pkgs }:
builtins.readDir ./.
|> builtins.attrNames
|> builtins.filter (p: p != "default.nix")
|> builtins.map (p: {
  name = p;
  value = pkgs.callPackage (./. + "/${p}") { };
})
|> builtins.listToAttrs
