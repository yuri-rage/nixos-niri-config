# apps Nix flake
#
#  desktop applications and custom launcher entries
#
# provides:
#   - system: gimp-with-plugins, kdenlive, obsidian, vesktop, zen-browser
#   - user:   custom desktop launcher entries
#
# required artifacts:
#   - desktop-entries/ (custom desktop launchers)

{ self, inputs, ... }:
{
  flake.nixosModules.apps =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        gimp-with-plugins
        kdePackages.kdenlive
        obsidian
        vesktop
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.homeModules.apps =
    { ... }:
    {
      imports = [ self.homeModules.common ];
      xdg.dataFile."applications" = {
        source = ./desktop-entries;
        recursive = true;
      };
    };
}
