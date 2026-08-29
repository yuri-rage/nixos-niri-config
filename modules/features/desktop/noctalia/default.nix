# noctalia Nix flake
#
#  desktop shell, application launcher, and bar integration
#
# provides:
#   - system: inputs.noctalia package
#   - user:   programs.noctalia with settings.toml, spotify plugin, and wallpapers
#
# required artifacts:
#   - settings.toml
#   - plugins/spotify (plugin directory + files)
#   - wallpaper/ (wallpaper directory + files)

{ self, inputs, ... }:
{
  flake.nixosModules.noctalia =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.homeModules.noctalia =
    { link, ... }:
    {
      imports = [
        self.homeModules.common
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia.enable = true;

      xdg.stateFile."noctalia/settings.toml".source =
        link "modules/features/desktop/noctalia/settings.toml";

      xdg.stateFile."noctalia/plugins/materialized/local/spotify".source =
        link "modules/features/desktop/noctalia/plugins/spotify";

      home.file."Pictures/Wallpapers".source = link "modules/features/desktop/noctalia/wallpaper";
    };
}
