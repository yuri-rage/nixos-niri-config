# voodoo-nix host Nix flake
#
#  host-specific composition for voodoo-nix (WSL2 environment)
#
# provides:
#   - nixosConfigurations.voodoo-nix
#   - homeConfigurations."yuri@voodoo-nix"
#
# required artifacts:
#   - (none)

{ self, inputs, ... }:
{
  config.flake.nixosConfigurations.voodoo-nix = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      self.nixosModules.voodooConfiguration
    ];
  };

  config.flake.homeConfigurations."yuri@voodoo-nix" =
    inputs.home-manager.lib.homeManagerConfiguration
      {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs self; };
        modules = [
          self.homeModules.yuriWslConfiguration
        ];
      };
}
