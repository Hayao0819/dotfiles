{ ... }:
{

  imports = [
    ./sheldon.nix
    ./powerline-go.nix
  ];

  # I use zsh, but bash and fish work just as well here. This will setup
  # the shell to use home-manager properly on startup, neat!
  programs.zsh = {
    # Install zsh
    enable = true;

    # ZSH Autosuggestions
    # The option `programs.zsh.enableAutosuggestions' defined in config
    # has been renamed to `programs.zsh.autosuggestion.enable'.
    autosuggestion.enable = true;

    # ZSH Completions
    enableCompletion = true;

    # ZSH Syntax Highlighting
    syntaxHighlighting.enable = true;

    shellAliases = {

      ".." = "cd ..";
      "...." = "cd ../..";

      # Updating system
      update-home = "home-manager switch --flake github:Hayao0819/dotfiles/nix --upgrade";
      update-system = "sudo nixos-rebuild switch --flake github:Hayao0819/dotfiles/nix --upgrade";

      nix-shell = "nix-shell --run zsh";
      nix-develop = "nix develop -c \"$SHELL\"";
    };

    # Extra manually typed configs (renamed from initExtra)
    initContent = builtins.readFile ./.zshrc;
  };
}
