{
  config,
  pkgs,
  lib,
  ...
}:
let
  # JackHack96/EasyEffects-Presets - Popular presets collection
  jackHack96Presets = pkgs.fetchFromGitHub {
    owner = "JackHack96";
    repo = "EasyEffects-Presets";
    rev = "master";
    sha256 = "sha256-Fo5Dj9jY8gXotyNWDYsMSKabQ3nZsm7tQEm5dRNq3OQ=";
  };

  # Digitalone1/EasyEffects-Presets - Loudness Equalizer
  digitalone1Presets = pkgs.fetchFromGitHub {
    owner = "Digitalone1";
    repo = "EasyEffects-Presets";
    rev = "master";
    sha256 = "sha256-PvPa0G+RZFEmx+7R7vFks1zSzzl4Y8bL1C5g7GNJA/8=";
  };
in
{
  options = {
    audio = {
      enable = lib.mkEnableOption "Audio configuration with PipeWire and EasyEffects";
    };
  };

  config = lib.mkIf config.audio.enable {
    home.packages = with pkgs; [
      easyeffects
      # Required LV2 plugins for presets
      lsp-plugins
      zam-plugins
      mda_lv2
    ];

    # Copy presets to EasyEffects config directory
    xdg.configFile = {
      # JackHack96 presets
      "easyeffects/output/AdvancedAutoGain.json".source = "${jackHack96Presets}/Advanced Auto Gain.json";
      "easyeffects/output/BassBoosted.json".source = "${jackHack96Presets}/Bass Boosted.json";
      "easyeffects/output/BassEnhancingPerfectEQ.json".source =
        "${jackHack96Presets}/Bass Enhancing + Perfect EQ.json";
      "easyeffects/output/Boosted.json".source = "${jackHack96Presets}/Boosted.json";
      "easyeffects/output/LoudnessAutogain.json".source = "${jackHack96Presets}/Loudness+Autogain.json";
      "easyeffects/output/PerfectEQ.json".source = "${jackHack96Presets}/Perfect EQ.json";

      # Digitalone1 presets (Loudness Equalizer)
      "easyeffects/output/LoudnessEqualizer.json".source =
        "${digitalone1Presets}/Loudness Equalizer.json";
    };

    # Autostart EasyEffects with the session
    xdg.configFile."autostart/easyeffects.desktop".text = ''
      [Desktop Entry]
      Name=Easy Effects
      Comment=Easy Effects audio effects
      Exec=easyeffects --gapplication-service
      Icon=com.github.wwmm.easyeffects
      Type=Application
      Categories=AudioVideo;Audio;
      StartupNotify=false
      X-GNOME-Autostart-enabled=true
    '';
  };
}
