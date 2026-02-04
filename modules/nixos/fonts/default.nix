# Font configuration for NixOS
# Migrated from Arch Linux package list
{ pkgs, ... }:

{
  # Enable fontconfig
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK JP" "Noto Serif" ];
        sansSerif = [ "Noto Sans CJK JP" "Noto Sans" ];
        monospace = [ "SauceCodePro Nerd Font Mono" "Source Han Code JP" "Noto Sans Mono CJK JP" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    # Font packages
    packages = with pkgs; [
      # Noto fonts family (Google's open source fonts)
      noto-fonts           # Basic Latin/Greek/Cyrillic
      noto-fonts-cjk-sans  # CJK (Chinese, Japanese, Korean) - Sans
      noto-fonts-cjk-serif # CJK (Chinese, Japanese, Korean) - Serif
      noto-fonts-color-emoji  # Emoji support

      # IPA fonts (Japanese typography standard)
      ipafont              # IPA Gothic and Mincho
      ipaexfont            # IPAex Gothic and Mincho (extended)

      # Source Han Code JP (Adobe + Google collaboration)
      source-han-code-jp   # Programming font for Japanese

      # Standard open source fonts
      carlito              # Calibri-compatible
      dejavu_fonts         # DejaVu font family
      liberation_ttf       # Liberation fonts (MS Office compatible)
      open-sans            # Open Sans

      # Nerd Fonts (programming fonts with icons)
      nerd-fonts.sauce-code-pro  # Source Code Pro with Nerd Font icons
    ];
  };
}
