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
    rev = "d77a61eb01c36e2c794bddc25423445331e99915";
    sha256 = "sha256-or5kH/vTwz7IO0Vz7W4zxK2ZcbL/P3sO9p5+EdcC2DA=";
  };

  # Digitalone1/EasyEffects-Presets - Loudness Equalizer
  digitalone1Presets = pkgs.fetchFromGitHub {
    owner = "Digitalone1";
    repo = "EasyEffects-Presets";
    rev = "347dc4dd0ada677a15db2676cd9a5082e2f0033a";
    sha256 = "sha256-DHuYj9IynIhjdEdISiBObauvVPbahcmzSmwhdr6puUU=";
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

      # Custom preset
      "easyeffects/output/ドンシャリマシマシベースチョモランマボーカル.json".source =
        ./presets + "/ドンシャリマシマシベースチョモランマボーカル.json";
    };

    # Enable EasyEffects service (autostart)
    services.easyeffects.enable = true;
  };
}
