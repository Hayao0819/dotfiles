# Dotfiles

Nix入門しました。

## NixOS

```shell
# Use boot if it's first time, else switch
sudo nixos-rebuild boot --flake github:Hayao0819/dotfiles/nix#XPS9350 --upgrade
```

## Home Manager

Install `home-manager`

<https://nix-community.github.io/home-manager/index.xhtml#ch-installation>

Apply them.

```shell
# Arch Linux
home-manager switch --flake github:Hayao0819/dotfiles/nix#archlinux

# Debian
home-manager switch --flake github:Hayao0819/dotfiles/nix#debian

# Generic Linux
home-manager switch --flake github:Hayao0819/dotfiles/nix#linux

# macOS
home-manager switch --flake github:Hayao0819/dotfiles/nix#darwin
```

## Special Thanks

- [watasuke102/dotfiles](https://github.com/watasuke102/dotfiles) 非常に参考にさせていただいております
- orzklv/nix 非常に参考にさせていただいております2️⃣
- [watasuke102/mit-sushi-ware](https://github.com/watasuke102/mit-sushi-ware) MIT-SUSHI-WARE ライセンス
