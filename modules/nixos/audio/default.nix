{
  config,
  lib,
  ...
}:
{
  options = {
    audio = {
      enable = lib.mkEnableOption "Audio configuration with PipeWire";
    };
  };

  config = lib.mkIf config.audio.enable {
    # Disable PulseAudio
    services.pulseaudio.enable = false;

    # Enable rtkit for real-time scheduling
    security.rtkit.enable = true;

    # Enable PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
