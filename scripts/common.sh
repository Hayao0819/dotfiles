#!/usr/bin/env bash
# Common utilities for all shell scripts

# =====================================
# Color definitions
# =====================================
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

# =====================================
# Logging functions
# =====================================

# Generic logging function
log_message() {
    local color="$1"
    local prefix="$2"
    shift 2
    echo -e "${color}[${prefix}]${NC} $*"
}

# Specific logging functions
print_info() { log_message "$BLUE" "INFO" "$@"; }
print_success() { log_message "$GREEN" "SUCCESS" "$@"; }
print_warning() { log_message "$YELLOW" "WARNING" "$@"; }
print_error() { log_message "$RED" "ERROR" "$@"; }
print_task() { echo -e "${BOLD}>>> $*${NC}"; }

# Aliases for compatibility
log_info() { print_info "$@"; }
log_success() { print_success "$@"; }
log_warning() { print_warning "$@"; }
log_error() { print_error "$@"; }

# =====================================
# Separator functions
# =====================================

print_separator() {
    echo "────────────────────────────────────────────────────────"
}

print_box_header() {
    local text="$1"
    local width=${2:-60}
    local padding=$(((width - ${#text} - 2) / 2))
    local line=""

    for ((i = 0; i < width; i++)); do
        line+="═"
    done

    echo "╔${line}╗"
    printf "║%*s%s%*s║\n" "${padding}" "" "${text}" $((width - padding - ${#text})) ""
    echo "╚${line}╝"
}

# =====================================
# System detection functions
# =====================================

is_nixos() {
    [ -f /etc/nixos/configuration.nix ] || [ -d /etc/nixos ]
}

is_darwin() {
    [[ "$OSTYPE" == "darwin"* ]]
}

is_arch() {
    [ -f /etc/arch-release ]
}

get_hostname() {
    hostname
}

# =====================================
# Nix helper functions
# =====================================

# Check if flake exists in current directory
check_flake_exists() {
    if [[ ! -f "flake.nix" ]]; then
        log_error "No flake.nix found in current directory"
        return 1
    fi
    return 0
}

# Run nix command with experimental features enabled
nix_cmd() {
    nix "$@" --extra-experimental-features 'nix-command flakes'
}

# Get list of configurations for a given type
get_nix_configs() {
    local config_type="$1"
    local configs=""

    # Try JSON method first
    configs=$(nix_cmd flake show . --json 2> /dev/null | jq -r ".${config_type} | keys[]?" 2> /dev/null || echo "")

    # Fallback to text parsing if JSON doesn't work
    if [[ -z "${configs}" ]]; then
        configs=$(nix_cmd flake show . 2>&1 | grep -A20 "${config_type}" | grep "│.*├\|│.*└" | sed 's/.*─//g' | sed 's/:.*//' | tr -d ' ' || echo "")
    fi

    echo "${configs}"
}

# Check if a configuration exists
config_exists() {
    local config_type="$1"
    local config_name="$2"

    if nix_cmd eval --quiet ".#${config_type}.${config_name}" 2> /dev/null; then
        return 0
    else
        return 1
    fi
}

# =====================================
# File and directory utilities
# =====================================

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "${dir}" ]]; then
        mkdir -p "${dir}"
    fi
}

# Create temp file with cleanup on exit
create_temp_file() {
    local temp_file
    temp_file=$(mktemp)
    # Add to cleanup list
    TEMP_FILES+=("${temp_file}")
    echo "${temp_file}"
}

# Cleanup function for temp files
cleanup_temp_files() {
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        rm -f "${TEMP_FILES[@]}"
    fi
}

# Array to store temp files
declare -a TEMP_FILES=()

# Setup cleanup trap only if script is being executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    trap cleanup_temp_files EXIT
fi

# =====================================
# Error tracking utilities
# =====================================

# Error counting variables (for validation scripts)
TOTAL_ERRORS=0
SYNTAX_ERRORS=0
RUNTIME_ERRORS=0
PACKAGE_ERRORS=0

# Track error with counter increment
track_error() {
    local error_type="${1:-TOTAL}"
    case "${error_type}" in
        SYNTAX)
            ((SYNTAX_ERRORS++))
            ((TOTAL_ERRORS++))
            ;;
        RUNTIME)
            ((RUNTIME_ERRORS++))
            ((TOTAL_ERRORS++))
            ;;
        PACKAGE)
            ((PACKAGE_ERRORS++))
            ((TOTAL_ERRORS++))
            ;;
        *)
            ((TOTAL_ERRORS++))
            ;;
    esac
}

# Print error summary
print_error_summary() {
    print_separator
    echo "Error Summary:"
    echo "  Syntax Errors:  ${SYNTAX_ERRORS}"
    echo "  Runtime Errors: ${RUNTIME_ERRORS}"
    echo "  Package Errors: ${PACKAGE_ERRORS}"
    echo "  Total Errors:   ${TOTAL_ERRORS}"
}

# =====================================
# Configuration detection
# =====================================

detect_config() {
    local hostname
    hostname=$(get_hostname)

    if is_nixos; then
        # Try to find matching NixOS configuration
        case "${hostname}" in
            *XPS* | *xps* | *9350*)
                echo "XPS9350"
                ;;
            *)
                log_warning "Unknown NixOS host: ${hostname}"
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

# =====================================
# Exit codes
# =====================================
export EXIT_SUCCESS=0
export EXIT_SYNTAX_ERROR=1
export EXIT_RUNTIME_ERROR=2
export EXIT_PACKAGE_ERROR=3

# =====================================
# Utility functions
# =====================================

# Check if command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Ask for confirmation
confirm() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-n}"

    local yn_prompt="[y/N]"
    if [[ "${default}" == "y" ]]; then
        yn_prompt="[Y/n]"
    fi

    read -p "${prompt} ${yn_prompt}: " -n 1 -r
    echo

    if [[ -z "${REPLY}" ]]; then
        REPLY="${default}"
    fi

    [[ "${REPLY}" =~ ^[Yy]$ ]]
}

# =====================================
# Exported functions for sourcing
# =====================================

# Export functions so they're available when sourced
export -f log_message print_info print_success print_warning print_error print_task
export -f log_info log_success log_warning log_error
export -f print_separator print_box_header
export -f is_nixos is_darwin is_arch get_hostname
export -f check_flake_exists nix_cmd get_nix_configs config_exists
export -f ensure_dir create_temp_file cleanup_temp_files
export -f track_error print_error_summary
export -f detect_config command_exists confirm
