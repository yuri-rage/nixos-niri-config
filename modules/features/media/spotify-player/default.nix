# spotify-player Nix flake
#
#  terminal Spotify client with daemon mode & MPRIS receiver
#
# provides:
#   - system: spotify-player binary
#   - user:   app.toml, theme.toml, and background daemon user systemd service
#
# required artifacts:
#   - app.toml
#   - theme.toml

{ self, ... }:
{
  flake.nixosModules.spotify-player =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        spotify-player
      ];
    };

  flake.homeModules.spotify-player =
    { link, pkgs, ... }:
    {
      imports = [ self.homeModules.common ];
      xdg.configFile."spotify-player/app.toml".source =
        link "modules/features/media/spotify-player/app.toml";
      xdg.configFile."spotify-player/theme.toml".source =
        link "modules/features/media/spotify-player/theme.toml";

      systemd.user.services.spotify-player = {
        Unit = {
          Description = "Spotify Player Daemon (MPRIS & Connect Receiver)";
          Documentation = [ "https://github.com/aome510/spotify-player" ];
          After = [
            "network-online.target"
            "sound.target"
          ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "forking";
          ExecStart = "${pkgs.spotify-player}/bin/spotify_player -d";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
