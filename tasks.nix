{
  inputs,
  system,
  pkgs,
}:
let
  hmBin = "${inputs.home-manager.packages.${system}.default}/bin/home-manager";

  mkApp = program: {
    type = "app";
    inherit program;
  };

  deploy = pkgs.writeShellScript "deploy" ''
    set -euo pipefail
    usage() {
      echo "Usage: deploy [--nixos <name>] [--home <name>] [--action switch|boot|test]"
      echo ""
      echo "  --nixos <name>   NixOS configuration name (e.g., XPS9350, WSL)"
      echo "  --home <name>    Home Manager configuration name (e.g., archlinux, darwin)"
      echo "  --action <act>   Action: switch (default), boot, test"
      echo ""
      echo "If no flags given, auto-detects based on OS."
    }

    nixos_config="" home_config="" action="switch"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --nixos) nixos_config="$2"; shift 2 ;;
        --home)  home_config="$2"; shift 2 ;;
        --action) action="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
      esac
    done

    if [ -f /etc/nixos/configuration.nix ] || [ -d /etc/nixos ]; then
      nixos_config="''${nixos_config:-$(hostname)}"
      echo ">>> Applying NixOS configuration: $nixos_config"
      sudo nixos-rebuild "$action" --flake ".#$nixos_config"
    fi

    if [ -n "$home_config" ]; then
      echo ">>> Applying Home Manager configuration: $home_config"
      ${hmBin} switch --flake ".#$home_config"
    fi
  '';
in
{
  default = mkApp (toString deploy);
  deploy = mkApp (toString deploy);

  update = mkApp (
    toString (
      pkgs.writeShellScript "update" ''
        nix flake update --extra-experimental-features 'nix-command flakes'
      ''
    )
  );

  check = mkApp (
    toString (
      pkgs.writeShellScript "check" ''
        nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
      ''
    )
  );

  clean = mkApp (
    toString (
      pkgs.writeShellScript "clean" ''
        set -euo pipefail
        echo ">>> Cleaning old generations..."
        if [ -f /etc/nixos/configuration.nix ]; then
          sudo nix-collect-garbage --delete-older-than 7d
        fi
        command -v home-manager >/dev/null && home-manager expire-generations "-7 days"
        nix-collect-garbage --delete-older-than 7d
      ''
    )
  );

  status = mkApp (
    toString (
      pkgs.writeShellScript "status" ''
        echo ">>> System Status"
        echo "Hostname: $(hostname)"
        if [ -f /etc/nixos/configuration.nix ]; then
          echo "--- NixOS Generation ---"
          nixos-rebuild list-generations 2>/dev/null | head -3
        fi
        if command -v home-manager >/dev/null; then
          echo "--- Home Manager Generation ---"
          home-manager generations | head -3
        fi
      ''
    )
  );
}
