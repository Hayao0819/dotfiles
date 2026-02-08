# Logind power management configuration
# Controls lid switch behavior based on power state
{ ... }:
{
  services.logind.settings.Login = {
    # When on AC power, ignore lid close (don't suspend)
    HandleLidSwitchExternalPower = "ignore";

    # When on battery, suspend on lid close (default behavior)
    HandleLidSwitch = "suspend";

    # When docked with external power, also ignore lid close
    HandleLidSwitchDocked = "ignore";
  };
}
