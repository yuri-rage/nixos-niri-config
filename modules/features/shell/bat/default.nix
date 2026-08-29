# bat Nix flake
#
#  syntax-highlighting cat clone with Catppuccin Mocha theme
#
# provides:
#   - system: programs.bat + 'cat' alias
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.bat =
    { ... }:
    {
      programs.bat = {
        enable = true;
        settings = {
          theme = "Catppuccin Mocha";
        };
      };

      environment.shellAliases = {
        cat = "bat --plain --paging=never";
      };
    };
}
