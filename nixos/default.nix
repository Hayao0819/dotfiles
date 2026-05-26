{ inputs, outputs, ... }:
# let there be dragons
with builtins;
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (conf: {
  name = conf;
  value = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs;
      hostname = conf;
    };
    modules = [
      # > Our main nixos configuration file <
      "${inputs.self}/nixos/${conf}/configuration.nix"
    ];
  };
})
|> listToAttrs
