{ pkgs, ... }:
{

  programs.fish = {
    enable = true;

    # Shell aliases (same as zsh)
    shellAliases = {
      ".." = "cd ..";
      "...." = "cd ../..";

      # Updating system
      update-home = "home-manager switch --flake github:Hayao0819/dotfiles/nix --upgrade";
      update-system = "sudo nixos-rebuild switch --flake github:Hayao0819/dotfiles/nix --upgrade";

      nix-shell = "nix-shell --run fish";
      nix-develop = "nix develop -c fish";
    };

    # Interactive shell initialization
    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Key bindings (use default emacs-style)
      set --erase --universal fish_key_bindings

      # Theme colors (from fish_frozen_theme.fish)
      set --global fish_color_autosuggestion brblack
      set --global fish_color_cancel -r
      set --global fish_color_command normal
      set --global fish_color_comment red
      set --global fish_color_cwd green
      set --global fish_color_cwd_root red
      set --global fish_color_end green
      set --global fish_color_error brred
      set --global fish_color_escape brcyan
      set --global fish_color_history_current --bold
      set --global fish_color_host normal
      set --global fish_color_host_remote yellow
      set --global fish_color_normal normal
      set --global fish_color_operator brcyan
      set --global fish_color_param cyan
      set --global fish_color_quote yellow
      set --global fish_color_redirection cyan --bold
      set --global fish_color_search_match white --background=brblack
      set --global fish_color_selection white --bold --background=brblack
      set --global fish_color_status red
      set --global fish_color_user brgreen
      set --global fish_color_valid_path --underline
      set --global fish_pager_color_completion normal
      set --global fish_pager_color_description yellow -i
      set --global fish_pager_color_prefix normal --bold --underline
      set --global fish_pager_color_progress brwhite --background=cyan
      set --global fish_pager_color_selected_background -r

      # Extra aliases for Linux/NixOS
      if test (uname) = "Linux"; and test -f /etc/nixos/configuration.nix
        alias open="xdg-open"
      end

      # Cargo
      fish_add_path -g $HOME/.cargo/bin

      # Golang
      set -gx GOPATH $HOME/.go
      fish_add_path -g $HOME/.go/bin

      # Local bin
      fish_add_path -g $HOME/.local/bin

      # Pyenv (if available)
      if command -q pyenv
        set -gx PYENV_ROOT $HOME/.pyenv
        fish_add_path -g $PYENV_ROOT/bin
        pyenv init - fish | source
      end

      # Volta (if available)
      if test -d $HOME/.volta
        fish_add_path -g $HOME/.volta/bin
      end
    '';

    # Plugins
    plugins = [
      # Fish plugin for fzf
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      # Autopair
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      # Done notifications
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
  };

  # Ensure fish is available
  home.packages = with pkgs; [
    fish
    fzf
  ];
}
