# fastfetch Nix flake
#
#  system information and hardware display tool with custom Starman ANSI art
#
# provides:
#   - system: fastfetch package + system-wide config.jsonc and starman.ansi
#
# required artifacts:
#   - config.jsonc
#   - starman.ansi

{ ... }:
{
  flake.nixosModules.fastfetch =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        fastfetch
      ];

      environment.etc = {
        "xdg/fastfetch/config.jsonc".source = ./config.jsonc;
        "xdg/fastfetch/starman.ansi".source = ./starman.ansi;
      };
    };
}
