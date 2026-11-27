# apps Nix flake
#
#  desktop applications, AppImage runtime support, and custom launcher entries
#
# provides:
#   - system:  gimp-with-plugins, kdenlive, obsidian, vesktop, zen-browser, solidcraft,
#              programs.appimage (appimage-run + binfmt)
#   - user:    custom desktop launcher entries, solidcraft self-integration opt-out
#   - package: solidcraft (wrapped latest-release AppImage + solidcraft-cli)
#
# required artifacts:
#   - desktop-entries/ (custom desktop launchers)
#   - inputs.solidcraft-appimage (flake input tracking the latest release)

{ self, inputs, ... }:
{
  flake.nixosModules.apps =
    { pkgs, ... }:
    {
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      environment.systemPackages = with pkgs; [
        gimp-with-plugins
        kdePackages.kdenlive
        obsidian
        vesktop
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        self.packages.${pkgs.stdenv.hostPlatform.system}.solidcraft
      ];
    };

  flake.homeModules.apps =
    { ... }:
    {
      imports = [ self.homeModules.common ];
      xdg.dataFile."applications" = {
        source = ./desktop-entries;
        recursive = true;
      };

      # SolidCraft's AppRun writes its own .desktop entry, icons, and ~/.local/bin/solidcraft-cli
      # when launched as a raw AppImage (e.g. via appimage-run), and never replaces an entry
      # written by an older release. The packaged launcher is used instead; this marker file
      # is AppRun's documented permanent opt-out.
      xdg.dataFile."solidcraft/no-desktop-integration".text = "";

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/discord" = [ "vesktop.desktop" ];
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.solidcraft =
        let
          pname = "solidcraft";
          version = "latest";
          src = inputs.solidcraft-appimage;
          contents = pkgs.appimageTools.extract { inherit pname version src; };
          desktopId = "io.tangencylabs.solidcraft";
        in
        pkgs.appimageTools.wrapType2 {
          inherit pname version src;

          # wrapped launches leave $APPIMAGE unset, which already skips AppRun's integration;
          # this makes the opt-out explicit
          extraBwrapArgs = [
            "--setenv"
            "SOLIDCRAFT_NO_DESKTOP_INTEGRATION"
            "1"
          ];

          extraInstallCommands = ''
            # desktop entry (Exec=solidcraft resolves to this wrapper), icons, mime types
            install -Dm444 ${contents}/usr/share/applications/${desktopId}.desktop -t $out/share/applications
            cp -r ${contents}/usr/share/icons $out/share/
            install -Dm444 ${contents}/usr/share/mime/packages/${desktopId}.xml -t $out/share/mime/packages
            install -Dm444 ${contents}/usr/share/metainfo/${desktopId}.metainfo.xml -t $out/share/metainfo

            # AppRun runs the bundled CLI when SOLIDCRAFT_APPIMAGE_CLI=1
            cat > $out/bin/solidcraft-cli <<EOF
            #!${pkgs.runtimeShell}
            SOLIDCRAFT_APPIMAGE_CLI=1 exec $out/bin/solidcraft "\$@"
            EOF
            chmod 755 $out/bin/solidcraft-cli
          '';

          meta = {
            description = "Parametric 3D CAD (latest release AppImage)";
            homepage = "https://github.com/tangency-labs/solidcraft";
            mainProgram = "solidcraft";
            platforms = [ "x86_64-linux" ];
          };
        };
    };
}
