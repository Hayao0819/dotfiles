{
  nix-darwin,
  inputs,
  outputs,
  ...
}:
{

  MacBook = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      ./macbook/configuration.nix
    ];
    specialArgs = {
      inherit inputs outputs;
    };
  };

}
