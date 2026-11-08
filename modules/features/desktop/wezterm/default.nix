# wezterm Nix flake
#
#  GPU-accelerated, feature-rich terminal emulator
#
# provides:
#   - user: programs.wezterm with wezterm.lua out-of-store link + open-in-wezterm.py nautilus extension
#
# required artifacts:
#   - wezterm.lua
#   - open-in-wezterm.py

{ self, ... }:
{
  flake.homeModules.wezterm =
    { link, ... }:
    {
      imports = [ self.homeModules.common ];

      programs.wezterm = {
        enable = true;
      };

      #  programs.wezterm.enable generates wezterm.lua only when `settings` or `extraConfig` is non-empty,
      #  so the xdg.configFile symlink below doesn't collide.
      xdg.configFile."wezterm/wezterm.lua".source = link "modules/features/desktop/wezterm/wezterm.lua";

      # Nautilus extension (harmless cruft if not using Nautilus)
      xdg.dataFile."nautilus-python/extensions/open-in-wezterm.py".source =
        link "modules/features/desktop/wezterm/open-in-wezterm.py";
    };
}
