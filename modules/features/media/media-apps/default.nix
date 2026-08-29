# media-apps Nix flake
#
#  video playback and streaming download utilities
#
# provides:
#   - system: vlc, yt-dlp
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.media-apps =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vlc
        yt-dlp
      ];
    };
}
