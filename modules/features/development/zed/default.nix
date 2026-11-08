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
          "text/rust" = [ "dev.zed.Zed.desktop" ];
          "text/javascript" = [ "dev.zed.Zed.desktop" ];
          "application/javascript" = [ "dev.zed.Zed.desktop" ];
          "application/typescript" = [ "dev.zed.Zed.desktop" ];
          "text/vnd.trolltech.linguist" = [ "dev.zed.Zed.desktop" ];
          "text/x-go" = [ "dev.zed.Zed.desktop" ];
          "text/x-zig" = [ "dev.zed.Zed.desktop" ];
          "text/css" = [ "dev.zed.Zed.desktop" ];
          "text/x-scss" = [ "dev.zed.Zed.desktop" ];
          "text/x-sass" = [ "dev.zed.Zed.desktop" ];
          "text/x-less" = [ "dev.zed.Zed.desktop" ];
          "text/x-java" = [ "dev.zed.Zed.desktop" ];
          "text/x-kotlin" = [ "dev.zed.Zed.desktop" ];
          "text/x-swift" = [ "dev.zed.Zed.desktop" ];
          "text/x-ruby" = [ "dev.zed.Zed.desktop" ];
          "text/x-php" = [ "dev.zed.Zed.desktop" ];
          "text/x-sql" = [ "dev.zed.Zed.desktop" ];
          "text/x-dockerfile" = [ "dev.zed.Zed.desktop" ];
          "text/x-makefile" = [ "dev.zed.Zed.desktop" ];
          "text/x-cmake" = [ "dev.zed.Zed.desktop" ];
          "text/x-ini" = [ "dev.zed.Zed.desktop" ];
          "text/x-config" = [ "dev.zed.Zed.desktop" ];
          "text/x-diff" = [ "dev.zed.Zed.desktop" ];
          "text/x-patch" = [ "dev.zed.Zed.desktop" ];
        };
      };
    };
}
