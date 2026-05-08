{
  inputs,
  outputs,
  ...
}:
with builtins;
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (conf: {
  name = conf;
  value = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs outputs;
    };
    modules = [
      # > Our main nixos configuration file <
      "${inputs.self}/darwin/${conf}/configuration.nix"
    ];
  };
})
|> listToAttrs

# {
#   MacBook = inputs.nix-darwin.lib.darwinSystem {
#     system = "aarch64-darwin";
#     modules = [
#       ./macbook/configuration.nix
#     ];
#     specialArgs = {
#       inherit inputs outputs;
#     };
#   };

# }
