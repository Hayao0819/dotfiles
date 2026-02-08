{
  ...
}:
{
  # Allow nixos-rebuild without password
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
