# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ flake, pkgs }:
with builtins;
# if you're curious what this thing do, just `cd pkgs && nix repl` and copy paste the content :)
readDir ./.
|> attrNames
|> filter (p: p != "default.nix")
|> map (p: {
  name = p;
  value = pkgs.callPackage (toPath "${flake}/pkgs/${p}") { };
})
|> listToAttrs

# Why do it manually when you can let nix do it self?)
# {
#   # example = pkgs.callPackage ./example { };
#   hello = pkgs.callPackage ./hello { };
#   roulette = pkgs.callPackage ./roulette { };
#   thunderbird-mcp = pkgs.callPackage ./thunderbird-mcp { };
# }
