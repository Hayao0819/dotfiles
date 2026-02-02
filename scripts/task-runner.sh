#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get current hostname
HOSTNAME=$(hostname)

# Function to print colored messages
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_task() { echo -e "${BOLD}>>> $1${NC}"; }

# Function to check if running on NixOS
is_nixos() {
  [ -f /etc/nixos/configuration.nix ] || [ -d /etc/nixos ]
}

# Function to check if running on Darwin
is_darwin() {
  [[ "$OSTYPE" == "darwin"* ]]
}

# Function to detect configuration name
detect_config() {
  if is_nixos; then
    # Try to find matching NixOS configuration
    case "$HOSTNAME" in
      *XPS* | *xps* | *9350*)
        echo "XPS9350"
        ;;
      *)
        print_warning "Unknown NixOS host: $HOSTNAME"
        echo "XPS9350" # Default fallback
        ;;
    esac
  elif is_darwin; then
    echo "darwin"
  else
    # Non-NixOS Linux (Arch, etc.)
    echo "archlinux"
  fi
}

# Function to show help
show_help() {
  cat <<EOF

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

  print_task "Applying NixOS configuration: $config"
  print_info "Action: $action"

  # Check if configuration exists
  if ! nix eval --quiet ".#nixosConfigurations.$config" 2>/dev/null; then
    print_error "Configuration '$config' not found!"
    print_info "Available configurations:"
    nix eval --quiet --json '.#nixosConfigurations' | jq -r 'keys[]' 2>/dev/null || true
    return 1
  fi

  # Build and apply
  sudo nixos-rebuild "$action" --flake ".#$config" $extra_args
  print_success "NixOS configuration applied!"
}

# Function to apply Home Manager configuration
apply_home() {
  local config="${1:-$(detect_config)}"
  local extra_args="${2:-}"

  print_task "Applying Home Manager configuration: $config"

  # Check if configuration exists
  if ! nix eval --quiet ".#homeConfigurations.$config" 2>/dev/null; then
    print_error "Configuration '$config' not found!"
    print_info "Available configurations:"
    nix eval --quiet --json '.#homeConfigurations' | jq -r 'keys[]' 2>/dev/null || true
    return 1
  fi

  # Apply Home Manager
  home-manager switch --flake ".#$config" $extra_args
  print_success "Home Manager configuration applied!"
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
        extra_args="$extra_args --dry-run"
        shift
        ;;
      --show-trace)
        extra_args="$extra_args --show-trace"
        shift
        ;;
      *)
        shift
        ;;
    esac
  done

  print_task "Full deployment for: $config"
  echo ""

  # Apply NixOS if applicable
  if is_nixos; then
    apply_nixos "$config" "$nixos_action" "$extra_args"
    echo ""
  fi

  # Apply Home Manager
  apply_home "$config" "$extra_args"

  echo ""
  print_success "Full deployment complete!"
}

# Function to update flake inputs
update_flake() {
  print_task "Updating flake inputs"
  nix flake update
  print_success "Flake inputs updated!"
  echo ""
  print_info "Run 'deploy' to apply the updates"
}

# Function to check flake
check_flake() {
  print_task "Running flake checks"
  nix flake check --extra-experimental-features 'nix-command flakes'
  print_success "All checks passed!"
}

# Function to clean old generations
clean_old() {
  print_task "Cleaning old generations"

  if is_nixos; then
    print_info "Cleaning NixOS generations older than 7 days..."
    sudo nix-collect-garbage --delete-older-than 7d
  fi

  print_info "Cleaning Home Manager generations..."
  home-manager expire-generations "-7 days"

  print_info "Cleaning user profile..."
  nix-collect-garbage --delete-older-than 7d

  print_success "Cleanup complete!"
}

# Function to show system status
show_status() {
  print_task "System Status"
  echo ""

  print_info "Hostname: $HOSTNAME"
  print_info "Detected config: $(detect_config)"

  if is_nixos; then
    echo ""
    print_info "NixOS Generation:"
    nixos-rebuild list-generations | head -3
  fi

  echo ""
  print_info "Home Manager Generation:"
  home-manager generations | head -3

  echo ""
  print_info "Flake inputs:"
  nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]' | sed 's/^/  - /'
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
  help|--help|-h)
    show_help
    ;;
  *)
    print_error "Unknown command: $1"
    show_help
    exit 1
    ;;
esac