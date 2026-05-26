# System-level NixOS modules
# These configure OS-level services, boot, networking, and core system behavior
{ inputs }:
with builtins;
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (mod: {
  name = mod;
  value = import "${inputs.self}/modules/nixos/system/${mod}";
})
|> listToAttrs
