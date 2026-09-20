# media-scripts Nix flake
#
#  custom automated video library importers for TV and Movie media
#
# provides:
#   - packages: import-movie, import-tv
#   - user:     import-movie, import-tv added to user PATH
#
# required artifacts:
#   - import-movie
#   - import-tv

{ self, ... }:
{
  flake.homeModules.media-scripts =
    { pkgs, ... }:
    {
      home.packages = with self.packages.${pkgs.stdenv.hostPlatform.system}; [
        import-movie
        import-tv
      ];
    };

  # Custom Flake Packages
  perSystem =
    { lib, pkgs, ... }:
    let
      wrapMediaScript =
        name: scriptPath:
        pkgs.runCommand name
          {
            nativeBuildInputs = [
              pkgs.makeWrapper
              pkgs.python3
            ];
          }
          ''
            mkdir -p $out/bin
            cp ${scriptPath} $out/bin/${name}
            chmod +x $out/bin/${name}
            patchShebangs $out/bin/${name}
            wrapProgram $out/bin/${name} \
              --prefix PATH : ${
                lib.makeBinPath [
                  pkgs.ffmpeg
                  pkgs.mkvtoolnix-cli
                ]
              }
          '';
    in
    {
      packages.import-movie = wrapMediaScript "import-movie" ./import-movie;
      packages.import-tv = wrapMediaScript "import-tv" ./import-tv;
    };
}
