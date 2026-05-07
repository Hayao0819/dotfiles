# NixOS modules organized by category
# - system: OS-level configuration (boot, networking, services)
# - user: User-facing applications and desktop environments
{ inputs }:
with builtins;
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (mod: {
  name = mod;
  value = import "${inputs.self}/modules/nixos/${mod}" { inherit inputs; };
})
|> listToAttrs

# {
#   # System-level modules
#   system = import ./system;

#   # User-level modules
#   user = import ./user;
# }
