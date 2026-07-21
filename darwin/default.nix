{
  inputs,
  outputs,
  ...
}:
builtins.readDir ./.
|> builtins.attrNames
|> builtins.filter (p: p != "default.nix")
|> builtins.map (conf: {
  name = conf;
  value = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs outputs;
    };
    modules = [
      "${inputs.self}/darwin/${conf}/configuration.nix"
    ];
  };
})
|> builtins.listToAttrs
