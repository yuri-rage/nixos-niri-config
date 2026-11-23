# wezterm Nix flake
#
#  GPU-accelerated, feature-rich terminal emulator
#
# provides:
#   - user: programs.wezterm with wezterm.lua out-of-store link
#           (package ships the nautilus-python "Open in WezTerm" extension)
#
# required artifacts:
#   - wezterm.lua

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

      # Nautilus "Open in WezTerm" comes from the wezterm package itself
      # (share/nautilus-python/extensions/wezterm-nautilus.py via the home profile).
    };
}
