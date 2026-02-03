#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common.sh"

# Get current hostname (local variable)
hostname=$(get_hostname)

# Function to show help
show_help() {
    cat << EOF

${BOLD}Nix Dotfiles Task Runner${NC}

${BOLD}USAGE:${NC}
  nix run . -- [COMMAND] [OPTIONS]
  nix run .#deploy -- [OPTIONS]  # Same as 'deploy' command

${BOLD}COMMANDS:${NC}
  deploy [CONFIG]    Apply both NixOS and Home Manager changes
  nixos [CONFIG]     Apply only NixOS system changes
  home [CONFIG]      Apply only Home Manager changes
  update            Update all flake inputs
  check             Run flake checks
  clean             Clean old generations
  status            Show current system status
  help              Show this help message

${BOLD}OPTIONS:${NC}
  --boot           Use 'boot' instead of 'switch' (NixOS only)
  --dry-run        Show what would be done without doing it
  --rollback       Rollback to previous generation
  --show-trace     Show detailed error traces

${BOLD}EXAMPLES:${NC}
  nix run .                      # Deploy all (auto-detect)
  nix run . -- deploy            # Deploy all (auto-detect)
  nix run . -- nixos XPS9350     # Apply NixOS for XPS9350
  nix run . -- home archlinux    # Apply Home Manager for Arch
  nix run . -- deploy --boot     # Deploy with boot option
  nix run . -- update            # Update flake inputs
  nix run . -- clean             # Clean old generations

${BOLD}CONFIG NAMES:${NC}
  NixOS:   XPS9350
  Home:    archlinux, darwin-stable, darwin-unstable

EOF
}

# Function to apply NixOS configuration
apply_nixos() {
    local config="${1:-$(detect_config)}"
    local action="${2:-switch}"
    local extra_args="${3:-}"

    if ! is_nixos; then
        print_error "Not running on NixOS!"
        return 1
    fi

    print_task "Applying NixOS configuration: ${config}"
    print_info "Action: ${action}"

    # Check if configuration exists
    if ! config_exists "nixosConfigurations" "${config}"; then
        print_error "Configuration '${config}' not found!"
        print_info "Available configurations:"
        get_nix_configs "nixosConfigurations"
        return 1
    fi

    # Build and apply
    sudo nixos-rebuild "${action}" --flake ".#${config}" ${extra_args:+${extra_args}}
    print_success "NixOS configuration applied!"
}

# Function to apply Home Manager configuration
apply_home() {
    local config="${1:-$(detect_config)}"
    local extra_args="${2:-}"

    print_task "Applying Home Manager configuration: ${config}"

    # Check if configuration exists
    if ! config_exists "homeConfigurations" "${config}"; then
        print_error "Configuration '${config}' not found!"
        print_info "Available configurations:"
        get_nix_configs "homeConfigurations"
        return 1
    fi

    # Apply Home Manager
    if command_exists home-manager; then
        home-manager switch --flake ".#${config}" ${extra_args:+${extra_args}}
        print_success "Home Manager configuration applied!"
    else
        print_error "home-manager command not found. Please install it first."
        return 1
    fi
}

# Function to deploy all
deploy_all() {
    local config="${1:-$(detect_config)}"
    local nixos_action="switch"
    local extra_args=""

    # Parse additional options
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --boot)
                nixos_action="boot"
                shift
                ;;
            --dry-run)
                extra_args="${extra_args} --dry-run"
                shift
                ;;
            --show-trace)
                extra_args="${extra_args} --show-trace"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    print_task "Full deployment for: ${config}"
    echo ""

    # Apply NixOS if applicable
    if is_nixos; then
        apply_nixos "${config}" "${nixos_action}" "${extra_args}"
        echo ""
    fi

    # Apply Home Manager
    apply_home "${config}" "${extra_args}"

    echo ""
    print_success "Full deployment complete!"
}

# Function to update flake inputs
update_flake() {
    print_task "Updating flake inputs"
    nix_cmd flake update
    print_success "Flake inputs updated!"
    echo ""
    print_info "Run 'deploy' to apply the updates"
}

# Function to check flake
check_flake() {
    print_task "Running flake checks"
    nix_cmd flake check
    print_success "All checks passed!"
}

# Function to clean old generations
clean_old() {
    print_task "Cleaning old generations"

    if is_nixos; then
        print_info "Cleaning NixOS generations older than 7 days..."
        sudo nix-collect-garbage --delete-older-than 7d
    fi

    if command_exists home-manager; then
        print_info "Cleaning Home Manager generations..."
        home-manager expire-generations "-7 days"
    fi

    print_info "Cleaning user profile..."
    nix-collect-garbage --delete-older-than 7d

    print_success "Cleanup complete!"
}

# Function to show system status
show_status() {
    print_task "System Status"
    echo ""

    print_info "Hostname: ${hostname}"
    print_info "Detected config: $(detect_config)"

    if is_nixos; then
        echo ""
        print_info "NixOS Generation:"
        nixos-rebuild list-generations | head -3
    fi

    if command_exists home-manager; then
        echo ""
        print_info "Home Manager Generation:"
        home-manager generations | head -3
    fi

    echo ""
    print_info "Flake inputs:"
    nix_cmd flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]' | sed 's/^/  - /'
}

# Main command dispatcher
case "${1:-deploy}" in
    deploy)
        shift || true
        deploy_all "$@"
        ;;
    nixos)
        shift || true
        apply_nixos "$@"
        ;;
    home)
        shift || true
        apply_home "$@"
        ;;
    update)
        update_flake
        ;;
    check)
        check_flake
        ;;
    clean)
        clean_old
        ;;
    status)
        show_status
        ;;
    help | --help | -h)
        show_help
        ;;
    *)
        print_error "Unknown command: ${1}"
        show_help
        exit 1
        ;;
esac
