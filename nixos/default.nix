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

# Why do it by hand, when nix can manage it yourself ?)
# {
#   XPS9350 = inputs.nixpkgs.lib.nixosSystem {
#     specialArgs = { inherit inputs outputs; };
#     modules = [
#       # > Our main nixos configuration file <
#       ./xps9350/configuration.nix
#     ];
#   };

#   WSL = inputs.nixpkgs.lib.nixosSystem {
#     specialArgs = { inherit inputs outputs; };
#     modules = [
#       # NixOS-WSL configuration
#       ./wsl/configuration.nix
#     ];
#   };

#   Installer = inputs.nixpkgs.lib.nixosSystem {
#     specialArgs = { inherit inputs outputs; };
#     modules = [
#       ./installer/configuration.nix
#     ];
#   };
# }
