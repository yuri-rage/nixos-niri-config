# makemkv Nix flake
#
#  optical disc ripping and video transcoding toolchain
#
# provides:
#   - system: makemkv (with archive fallback URLs), ffmpeg, mkvtoolnix-cli
#
# required artifacts:
#   - (none)
#
# TODO: re-evaluate versioning once makemkv.com is restored

{ ... }:
{
  flake.nixosModules.makemkv =
    { pkgs, ... }:
    {
      # Media Transcoding & Optical Disc Ingest
      environment.systemPackages = with pkgs; [
        ffmpeg
        mkvtoolnix-cli
        (makemkv.overrideAttrs (_old: {
          srcs = [
            (pkgs.fetchurl {
              urls = [
                "https://web.archive.org/web/20260701000000/https://www.makemkv.com/download/makemkv-bin-1.18.4.tar.gz"
                "https://web.archive.org/web/https://www.makemkv.com/download/makemkv-bin-1.18.4.tar.gz"
                "https://www.makemkv.com/download/makemkv-bin-1.18.4.tar.gz"
              ];
              hash = "sha256-zuVt4LqlUxq+0WvYYnQtMI13K0q02uFu6GW/dPBKFgg=";
            })
            (pkgs.fetchurl {
              urls = [
                "https://web.archive.org/web/20260701000000/https://www.makemkv.com/download/makemkv-oss-1.18.4.tar.gz"
                "https://web.archive.org/web/https://www.makemkv.com/download/makemkv-oss-1.18.4.tar.gz"
                "https://www.makemkv.com/download/makemkv-oss-1.18.4.tar.gz"
              ];
              hash = "sha256-hZAGNkjULsKpWLdFc9cCLw9MM05OT+fdU7cMbnSLpFM=";
            })
          ];
        }))
      ];
    };
}
