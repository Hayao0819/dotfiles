#!/usr/bin/env bash
echo "Testing NixOS configuration evaluation to catch package errors:"
for config in $(nix flake show . --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]?' 2>/dev/null); do
    echo -n "  Checking $config... "
    if nix eval --extra-experimental-features 'nix-command flakes' \
        .#nixosConfigurations.$config.config.system.build.toplevel \
        --apply 'x: null' 2>&1 | grep -q error; then
        echo "ERROR"
    else
        echo "OK"
    fi
done