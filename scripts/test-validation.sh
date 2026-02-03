#!/usr/bin/env bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "${SCRIPT_DIR}/common.sh"

print_task "Testing NixOS configuration evaluation to catch package errors"
configs=$(get_nix_configs "nixosConfigurations")

if [[ -z "$configs" ]]; then
    print_warning "No NixOS configurations found"
    exit 0
fi

while IFS= read -r config; do
    echo -n "  Checking $config... "
    if nix_cmd eval --quiet \
        ".#nixosConfigurations.$config.config.system.build.toplevel" \
        --apply 'x: null' 2>&1 | grep -q error; then
        print_error "ERROR"
    else
        print_success "OK"
    fi
done <<< "$configs"
