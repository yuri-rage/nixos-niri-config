# docker Nix flake
#
#  container runtime virtualization, daemon configuration, and compose tooling
#
# provides:
#   - system: virtualisation.docker, weekly autoPrune, docker-compose CLI
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.docker =
    { pkgs, ... }:
    {
      virtualisation.docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };

      environment.systemPackages = with pkgs; [
        docker-compose
      ];
    };
}
