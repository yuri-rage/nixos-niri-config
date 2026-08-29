# rage-nix host Nix flake
#
#  host-specific composition and hardware configuration for rage-nix workstation
#
# provides:
#   - nixosConfigurations.rage-nix
#   - homeConfigurations.yuri
#
# required artifacts:
#   - (none)

{ self, inputs, ... }:
{
  config.flake.nixosConfigurations.rage-nix = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      self.nixosModules.rageConfiguration
    ];
  };

  config.flake.homeConfigurations.yuri = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    extraSpecialArgs = { inherit inputs self; };
    modules = [
      self.homeModules.yuriConfiguration
    ];
  };
}
