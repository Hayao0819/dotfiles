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

# {
#   audio = import ./audio;
#   boot = import ./boot;
#   common = import ./common;
#   fonts = import ./fonts;
#   locale = import ./locale;
#   logind = import ./logind;
#   network = import ./network;
#   nix-ld = import ./nix-ld;
#   nixpkgs = import ./nixpkgs;
#   printing = import ./printing;
#   tuned = import ./tuned;
#   virtualization = import ./virtualization;
#   zsh = import ./zsh;
# }
