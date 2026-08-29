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
    { pkgs, ... }:
    {
      packages.import-movie = pkgs.writeScriptBin "import-movie" (
        builtins.replaceStrings [ "#!/usr/bin/env python3" ] [ "#!${pkgs.python3}/bin/python3" ] (
          builtins.readFile ./import-movie
        )
      );
      packages.import-tv = pkgs.writeScriptBin "import-tv" (
        builtins.replaceStrings [ "#!/usr/bin/env python3" ] [ "#!${pkgs.python3}/bin/python3" ] (
          builtins.readFile ./import-tv
        )
      );
    };
}
