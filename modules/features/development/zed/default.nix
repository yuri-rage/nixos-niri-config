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

      xdg.configFile."mimeapps.list".force = true;
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/plain" = [ "dev.zed.Zed.desktop" ];
          "text/markdown" = [ "dev.zed.Zed.desktop" ];
          "text/x-nix" = [ "dev.zed.Zed.desktop" ];
          "text/x-c" = [ "dev.zed.Zed.desktop" ];
          "text/x-c++" = [ "dev.zed.Zed.desktop" ];
          "text/x-python" = [ "dev.zed.Zed.desktop" ];
          "text/x-lua" = [ "dev.zed.Zed.desktop" ];
          "text/x-shellscript" = [ "dev.zed.Zed.desktop" ];
          "text/x-typst" = [ "dev.zed.Zed.desktop" ];
          "application/x-typst" = [ "dev.zed.Zed.desktop" ];
          "application/json" = [ "dev.zed.Zed.desktop" ];
          "application/toml" = [ "dev.zed.Zed.desktop" ];
          "application/x-yaml" = [ "dev.zed.Zed.desktop" ];
          "text/yaml" = [ "dev.zed.Zed.desktop" ];
          "application/xml" = [ "dev.zed.Zed.desktop" ];
          "text/xml" = [ "dev.zed.Zed.desktop" ];
        };
      };
    };
}
