{ inputs, outputs, ... }:
{
  termux = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-linux";
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
      overlays = [
        outputs.overlays.additions
        outputs.overlays.unstable-packages
        outputs.overlays.modifications
        outputs.overlays.llm-agents
      ];
    };
    modules = [ ./termux ];
    extraSpecialArgs = { inherit inputs outputs; };
  };
}
