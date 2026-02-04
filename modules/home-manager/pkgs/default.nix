{ config
, pkgs
, lib
, inputs
, ...
}:
let
  # llm-agents packages (ccstatusline, etc.)
  llm-agents-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  # Package sets for different targets
  macos = import ./osx.nix { inherit pkgs; };
  linux = import ./linux.nix { inherit pkgs; };
  globals = import ./global.nix { inherit pkgs llm-agents-pkgs; };

  # Check if the target is MacOS or Linux
  isMacOS =
    pkgs.stdenv.hostPlatform.system == "aarch64-darwin"
    || pkgs.stdenv.hostPlatform.system == "x86_64-darwin";
in
{
  options = {
    packages = {
      isMacOS = lib.mkOption {
        type = lib.types.bool;
        default = isMacOS;
        description = "Is installed packages are MacOS targetted.";
      };
    };
  };

  config = {
    # Packages to be installed on my machine
    home.packages =
      if config.packages.isMacOS
      then globals ++ macos
      else globals ++ linux;
  };
}
