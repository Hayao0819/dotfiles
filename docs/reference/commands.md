# Commands Reference

## Quick Deploy (Task Runner)

```bash
nix run .                          # Auto-detect and deploy all
nix run . -- XPS9350 switch        # Deploy specific config
nix run .#update                   # Update flake inputs
nix run .#check                    # Run flake validation
nix run .#clean                    # Clean old generations
nix run .#status                   # Show system information
```

## NixOS

```bash
sudo nixos-rebuild switch --flake .#XPS9350
sudo nixos-rebuild boot --flake .#XPS9350    # Apply on next boot
sudo nixos-rebuild test --flake .#XPS9350    # Test without making default
```

> **重要**: XPS9350（NixOSシステム）では、Home ManagerがNixOSモジュールとして統合されています。
> `home-manager switch`を使用しないでください。代わりに`sudo nixos-rebuild switch`を使用してください。
> これにより、システムとHome Managerの設定が同時に適用されます。

### 適用後の確認

```bash
# dconf設定の確認（GNOME拡張機能など）
dconf dump /org/gnome/shell/

# 有効な拡張機能の確認
dconf read /org/gnome/shell/enabled-extensions
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
