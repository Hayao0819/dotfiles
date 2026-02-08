# NixOS modules organized by category
# - system: OS-level configuration (boot, networking, services)
# - user: User-facing applications and desktop environments
{
  # System-level modules
  system = import ./system;

  # User-level modules
  user = import ./user;
}
