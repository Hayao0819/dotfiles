# Validation Guide

## Quick Check
```bash
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators'
```

## Full Validation Script
```bash
#!/bin/bash
# Add untracked files
git add .

# Check syntax
nix flake check --extra-experimental-features 'nix-command flakes pipe-operators' --show-trace || exit 1

# Check NixOS configs
for cfg in $(nix flake show . --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]?' 2>/dev/null); do
    echo "Checking $cfg..."
    nix eval --extra-experimental-features 'nix-command flakes' \
        .#nixosConfigurations.$cfg.config.system.build.toplevel \
        --apply 'x: null' 2>&1 | grep -q error && echo "ERROR" && exit 2
done

# Check Home Manager
for cfg in $(nix flake show . --json 2>/dev/null | jq -r '.homeConfigurations | keys[]?' 2>/dev/null); do
    echo "Checking $cfg..."
    nix eval --extra-experimental-features 'nix-command flakes' \
        .#homeConfigurations.$cfg.activationPackage \
        --apply 'x: null' 2>&1 | grep -q error && echo "ERROR" && exit 2
done

# Dry-run build
nix build --dry-run --extra-experimental-features 'nix-command flakes' \
    .#nixosConfigurations.XPS9350.config.system.build.toplevel || exit 3
```

## When to Run
- After any .nix file edit
- Before commits
- After adding packages/modules
