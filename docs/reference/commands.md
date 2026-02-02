# Commands Reference

## Quick Deploy (Task Runner)
```bash
nix run .                          # Auto-detect and deploy all
nix run . -- deploy XPS9350        # Deploy specific config
nix run . -- nixos                 # NixOS only
nix run . -- home archlinux        # Home Manager only
nix run . -- update                # Update flake inputs
nix run . -- clean                 # Clean old generations
```

## NixOS
```bash
sudo nixos-rebuild switch --flake .#XPS9350
sudo nixos-rebuild boot --flake .#XPS9350    # Apply on next boot
```

## Home Manager
```bash
# Arch Linux
nix run github:nix-community/home-manager -- switch --flake .#archlinux

# From remote
nix run github:nix-community/home-manager -- switch --flake github:Hayao0819/dotfiles/nix#hayao@stable
```

## Darwin (macOS)
```bash
nix run github:nix-community/home-manager -- switch --flake .#darwin-stable
```

## Development
```bash
nix-shell           # Enter dev shell
nix fmt             # Format files
nix flake update    # Update all inputs
```