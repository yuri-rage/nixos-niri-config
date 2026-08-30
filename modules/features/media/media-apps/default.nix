# media-apps Nix flake
#
#  video playback and streaming download utilities
#
# provides:
#   - system: qbittorrent, vlc, yt-dlp
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.media-apps =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        qbittorrent
        vlc
        yt-dlp
      ];
    };
}
