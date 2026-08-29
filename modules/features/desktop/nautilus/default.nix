# nautilus Nix flake
#
#  fully self-contained desktop file manager module
#
# provides:
#   - system: nautilus binary + extensions + gvfs + tumbler + udisks2
#   - user:   nautilus dconf preferences + desktop launcher entry
#
# required artifacts:
#   - ~/.local/share/nautilus-python/extensions/open-in-foot.py (provided by foot module)

{ ... }:
{
  flake.nixosModules.nautilus =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        nautilus
        # extensions:
        file-roller
        nautilus-python
        sushi
      ];

      services.gvfs.enable = true;
      services.tumbler.enable = true;
      services.udisks2.enable = true;
    };

  flake.homeModules.nautilus =
    { ... }:
    {
      # desktop entry so launchers index "Nautilus"
      xdg.desktopEntries."org.gnome.Nautilus" = {
        name = "Nautilus";
        genericName = "File Manager";
        comment = "Access and organize files";
        exec = "nautilus --new-window %U";
        icon = "org.gnome.Nautilus";
        terminal = false;
        type = "Application";
        categories = [
          "GNOME"
          "GTK"
          "Utility"
          "Core"
          "FileManager"
        ];
        mimeType = [ "inode/directory" ];
        actions = {
          "new-window" = {
            name = "New Window";
            exec = "nautilus --new-window";
          };
        };
      };

      dconf.settings = {
        "org/gnome/nautilus/preferences" = {
          always-use-location-entry = true;
          show-create-link = true;
          show-delete-permanently = true;
        };
      };
    };
}
