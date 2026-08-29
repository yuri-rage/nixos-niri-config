# foot Nix flake
#
#  fast, lightweight Wayland terminal emulator and server
#
# provides:
#   - user: programs.foot with foot.ini out-of-store link + open-in-foot.py nautilus extension
#
# required artifacts:
#   - foot.ini
#   - open-in-foot.py

{ self, ... }:
{
  flake.homeModules.foot =
    { link, ... }:
    {
      imports = [ self.homeModules.common ];

      programs.foot = {
        enable = true;
        server.enable = true;
      };

      #  programs.foot.enable generates foot.ini only when `settings` is non-empty,
      #  so the xdg.configFile symlink below doesn't collide. Don't add settings here.
      xdg.configFile."foot/foot.ini".source = link "modules/features/desktop/foot/foot.ini";

      # Nautilus extension (harmless cruft if not using Nautilus)
      xdg.dataFile."nautilus-python/extensions/open-in-foot.py".source =
        link "modules/features/desktop/foot/open-in-foot.py";
    };
}
