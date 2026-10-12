# makemkv Nix flake
#
#  optical disc ripping and video transcoding toolchain
#
# provides:
# provides:
#   - system: makemkv, ffmpeg, mkvtoolnix-cli
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.makemkv =
    { pkgs, ... }:
    {
      # Media Transcoding & Optical Disc Ingest
      environment.systemPackages = with pkgs; [
        ffmpeg
        mkvtoolnix-cli
        makemkv
      ];
    };
}
