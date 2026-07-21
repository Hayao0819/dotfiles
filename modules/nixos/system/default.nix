{ inputs }:
builtins.readDir ./.
|> builtins.attrNames
|> builtins.filter (p: p != "default.nix")
|> builtins.map (mod: {
  name = mod;
  value = import "${inputs.self}/modules/nixos/system/${mod}";
})
|> builtins.listToAttrs
