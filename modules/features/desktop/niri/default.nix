# niri Nix flake
#
#  scrollable-tiling Wayland window manager and compositor
#
# provides:
#   - system: niri compositor + polkit + xdg-desktop-portal-gtk
#   - system: greetd auto-login integration (configurable via rage.niri.autoLoginUser)
#   - user:   niri out-of-store config.kdl symlink
#
# required artifacts:
#   - config.kdl

{ self, ... }:
{
  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.rage.niri;
    in
    {
      options.rage.niri.autoLoginUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "User to automatically log in to Niri on boot via greetd.";
      };

      config = {
        programs.niri.enable = true;
        security.polkit.enable = true;

        environment.systemPackages = with pkgs; [
          hyprpicker
          xwayland-satellite
        ];

        # Configure greetd auto-login only when autoLoginUser is specified
        services.greetd = lib.mkIf (cfg.autoLoginUser != null) {
          enable = true;
          settings =
            let
              session = {
                command = "${pkgs.niri}/bin/niri-session";
                user = cfg.autoLoginUser;
              };
            in
            {
              initial_session = session;
              default_session = session;
            };
        };

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.niri = {
            default = lib.mkForce [ "gtk" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
          };
        };
      };
    };

  flake.homeModules.niri =
    { link, ... }:
    {
      imports = [ self.homeModules.common ];
      xdg.configFile."niri/config.kdl".source = link "modules/features/desktop/niri/config.kdl";
    };
}
