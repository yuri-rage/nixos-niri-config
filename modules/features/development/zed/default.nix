# zed Nix flake
#
#  fully self-contained zed editor module
#
# provides:
#   - system: zed-editor package
#   - user:   zed settings out-of-store symlink
#
# required artifacts:
#   - settings.json

{ self, ... }:
{
  flake.nixosModules.zed =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.zed-editor ];
    };

  flake.homeModules.zed =
    { link, ... }:
    {
      imports = [ self.homeModules.common ];
      xdg.configFile."zed/settings.json".source = link "modules/features/development/zed/settings.json";
    };
}
