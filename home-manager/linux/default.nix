# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  ...
}:
{
  imports = [
    # Centralized nixpkgs configuration
    outputs.modules.common.nixpkgs
  ]
  ++ (with outputs.modules.home-manager; [
    git
    gh
    zsh
    fish
    direnv
    pkgs
    gnome
    wallpapers
    llm
    xdg
    theme
    audio
    osint
  ]);

  home = {
    username = "hayao";
    homeDirectory = "/home/hayao";
    enableNixpkgsReleaseCheck = false;
  };

  # Enable audio with PipeWire and EasyEffects
  audio.enable = true;

  # OnlyOffice Desktop Editors configuration
  # GPU acceleration and Japanese language settings
  programs.onlyoffice = {
    enable = true;
    package = null; # Package is installed via NixOS system packages
    settings = {
      editorWindowMode = false;
      titlebar = "custom";
      # appdata contains JSON settings (base64 encoded):
      # {"username":"hayao","docopenmode":"edit","restart":true,"langid":"ja-JP",
      #  "uiscaling":"100","uitheme":"theme-white","editorwindowmode":false,
      #  "spellcheckdetect":"auto","usegpu":true}
      appdata = "@ByteArray(eyJ1c2VybmFtZSI6ImhheWFvIiwiZG9jb3Blbm1vZGUiOiJlZGl0IiwicmVzdGFydCI6dHJ1ZSwibGFuZ2lkIjoiamEtSlAiLCJ1aXNjYWxpbmciOiIxMDAiLCJ1aXRoZW1lIjoidGhlbWUtd2hpdGUiLCJlZGl0b3J3aW5kb3dtb2RlIjpmYWxzZSwic3BlbGxjaGVja2RldGVjdCI6ImF1dG8iLCJ1c2VncHUiOnRydWV9)";
    };
  };

  # Enable OSINT tools
  osint = {
    enable = true;
    sherlock.enable = true;
    maigret.enable = true;
    holehe.enable = true;
    ghunt.enable = true;
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
