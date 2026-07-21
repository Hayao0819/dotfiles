_: {
  services.logind.settings.Login = {
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
