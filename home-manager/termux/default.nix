# Home Manager configuration for Termux (Android)
# CLI-only environment: no systemd, no GUI, aarch64-linux
{
  outputs,
  ...
}:
let
  # Termux username is assigned by Android (e.g., u0_a254)
  # builtins.getEnv requires --impure flag at build time
  envUser = builtins.getEnv "USER";
  username = if envUser != "" then envUser else "termux-user";
in
{
  imports = [
    # Centralized nixpkgs configuration
    ../../modules/common/nixpkgs.nix
  ]
  ++ (with outputs.modules.home-manager; [
    git
    gh
    zsh
    fish
    pkgs
    llm
    xdg
  ]);

  # Termux: only install global packages (no desktop packages)
  packages.isHeadless = true;

  home = {
    inherit username;
    homeDirectory = "/data/data/com.termux/files/home";
    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true;

  # NOTE: No systemd.user.startServices - Termux does not have systemd

  home.stateVersion = "24.11";
}
