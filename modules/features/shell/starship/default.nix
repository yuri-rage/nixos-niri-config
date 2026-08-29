# starship Nix flake
#
#  cross-shell prompt with custom presets and cloud/git integrations
#
# provides:
#   - system: programs.starship configured with starship.toml
#
# required artifacts:
#   - starship.toml

{ ... }:
{
  flake.nixosModules.starship =
    { ... }:
    {
      programs.starship = {
        enable = true;
        settings = fromTOML (builtins.readFile ./starship.toml);
      };
    };
}
