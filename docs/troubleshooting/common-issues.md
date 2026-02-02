# Troubleshooting

## Common Issues

### Infinite Recursion
**Causes:**
- Circular module references
- Using package attrs in `nixpkgs.config`
- Missing `mkIf` for conditional config

**Fix:**
```nix
# Always use mkIf
config = mkIf cfg.enable { ... };
```

### Package Not Found
```bash
# Check if package exists
nix search nixpkgs packageName

# Check in specific channel
nix search github:NixOS/nixpkgs/nixos-24.11 packageName
```

### Attribute Not Found
- Verify imports in flake.nix
- Check module paths
- Use `nix repl` to explore

## Debug Commands

```bash
# Show traces
nix flake check --show-trace
nix build --show-trace .#config

# Find option declarations
nix repl
:l <nixpkgs>
:p options.networking.hostName.declarationPositions

# Force rebuild (bypass cache)
nixos-rebuild switch --flake . --option eval-cache false

# Clean old packages
nix-collect-garbage -d
```

## Error Assertions
```nix
assertions = [{
  assertion = config.option != null;
  message = "Option X requires Y";
}];
```