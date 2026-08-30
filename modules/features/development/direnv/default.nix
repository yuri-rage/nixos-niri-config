# direnv Nix flake
#
#  per-directory environment integration with nix-direnv caching
#
# provides:
#   - system: programs.direnv + nix-direnv integration
#   - user:   programs.direnv + nix-direnv integration + direnv.toml symlink
#
# required artifacts:
#   - direnv.toml

{ self, ... }:
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
    { link, ... }:
    {
      imports = [ self.homeModules.common ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      xdg.configFile."direnv/direnv.toml".source = link "modules/features/development/direnv/direnv.toml";
    };
}
