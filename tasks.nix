# Task runner applications
# Separated from flake.nix for maintainability
{
  inputs,
  system,
  pkgs,
}:
let
  # Copy scripts to a derivation so they can find each other
  scriptsDir = pkgs.stdenvNoCC.mkDerivation {
    name = "dotfiles-scripts";
    src = ./scripts;
    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out/
      chmod +x $out/*.sh
    '';
  };

  # Create a wrapper that provides necessary tools
  taskRunner = pkgs.writeShellScript "dotfiles-task-runner" ''
    #!/usr/bin/env bash
    export PATH="${pkgs.jq}/bin:${pkgs.git}/bin:${
      inputs.home-manager.packages.${system}.default
    }/bin:$PATH"
    exec ${pkgs.bash}/bin/bash ${scriptsDir}/task-runner.sh "$@"
  '';
in
{    # Default app - the main task runner
default = {
  type = "app";
  program = toString taskRunner;
};

# Alias for deployment
deploy = {
  type = "app";
  program = toString taskRunner;
};

# Quick access apps for specific tasks
update = {
  type = "app";
  program = toString (
    pkgs.writeShellScript "update" ''
      ${taskRunner} update
    ''
  );
};

check = {
  type = "app";
  program = toString (
    pkgs.writeShellScript "check" ''
      ${taskRunner} check
    ''
  );
};

clean = {
  type = "app";
  program = toString (
    pkgs.writeShellScript "clean" ''
      ${taskRunner} clean
    ''
  );
};

status = {
  type = "app";
  program = toString (
    pkgs.writeShellScript "status" ''
      ${taskRunner} status
    ''
  );
};
}
