{ config
, pkgs
, lib
, inputs
, ...
}:
let
  # Package sets for different targets
  macos = import ./osx.nix { inherit pkgs; };
  linux = import ./linux.nix { inherit pkgs; };
  globals = import ./global.nix { inherit pkgs; };

  # llm-agents packages (ccstatusline, etc.)
  llm-agents-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

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
      (if config.packages.isMacOS
      then globals ++ macos
      else globals ++ linux)
      ++ [
        # Claude Code statusline
        llm-agents-pkgs.ccstatusline
      ];
  };
}
