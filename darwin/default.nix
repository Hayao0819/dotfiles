{
  inputs,
  outputs,
  ...
}:
{

  MacBook = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      ./macbook/configuration.nix
    ];
    specialArgs = {
      inherit inputs outputs;
    };
  };

}
