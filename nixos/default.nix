{ inputs, outputs, ... }:
builtins.readDir ./.
|> builtins.attrNames
|> builtins.filter (p: p != "default.nix")
|> builtins.map (conf: {
  name = conf;
  value = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs;
      hostname = conf;
    };
    modules = [
      "${inputs.self}/nixos/${conf}/configuration.nix"
    ];
  };
})
|> builtins.listToAttrs
