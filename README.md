# Dotfiles

Nix入門しました。

# Installation

## NixOS

```shell
# Use boot if it's first time, else switch
sudo nixos-rebuild boot --flake github:Hayao0819/dotfiles/nix#Inspiron5490 --upgrade
```

## Home Manager

```shell
# Any Linux
## Stable
nix run github:nix-community/home-managner -- switch --flake github:Hayao0819/dotfiles/nix#hayao@stable
## Unstable
nix run github:nix-community/home-managner -- switch --flake github:Hayao0819/dotfiles/nix#hayao@unstable

# MacBook
## Stable
nix run github:nix-community/home-managner -- switch --flake github:Hayao0819/dotfiles/nix#darwin-stable
## Unstable
nix run github:nix-community/home-managner -- switch --flake github:Hayao0819/dotfiles/nix#darwin-unstable
```

## Special Thanks

- [watasuke102/dotfiles](https://github.com/watasuke102/dotfiles) 非常に参考にさせていただいております
- [orzklv/nix](https://github.com/orzklv/nix) 非常に参考にさせていただいております2️⃣
- [watasuke102/mit-sushi-ware](https://github.com/watasuke102/mit-sushi-ware) MIT-SUSHI-WARE ライセンス
