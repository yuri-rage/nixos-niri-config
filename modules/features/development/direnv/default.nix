# direnv Nix flake
#
#  per-directory environment integration with nix-direnv caching
#
# provides:
#   - system: programs.direnv + nix-direnv integration
#   - user:   programs.direnv + nix-direnv integration
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.direnv =
    { ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

  flake.homeModules.direnv =
    { ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
}
