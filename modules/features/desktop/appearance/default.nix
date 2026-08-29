# appearance Nix flake
#
#  fully self-contained desktop theming, fonts, and styling module
#
# provides:
#   - system:  workstation fonts + icon theme packages + dconf service
#   - user:    GTK theme + icon theme + cursor + font scaling + file chooser preferences
#   - package: material-black-blueberry-suru icon theme
#
# required artifacts:
#   - (none)

{ self, ... }:
{
  flake.nixosModules.appearance =
    { pkgs, ... }:
    {
      programs.dconf.enable = true;

      environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        papirus-icon-theme
        self.packages.${pkgs.stdenv.hostPlatform.system}.material-black-blueberry-suru
      ];

      fonts.packages = with pkgs; [
        fira
        inter
        nerd-fonts.fira-code
        nerd-fonts.hack
        nerd-fonts.meslo-lg
        nerd-fonts.noto
      ];
    };

  flake.homeModules.appearance =
    { pkgs, ... }:
    {
      imports = [ self.homeModules.common ];

      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        package = pkgs.rose-pine-cursor;
        name = "BreezeX-RosePine-Linux";
        size = 28;
      };

      gtk = {
        enable = true;
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3-dark";
        };
        font = {
          name = "Inter";
          size = 9;
        };
        iconTheme = {
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.material-black-blueberry-suru;
          name = "Material-Black-Blueberry-Suru";
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Material-Black-Blueberry-Suru";
          font-name = "Inter 9";
          document-font-name = "Inter 9";
          monospace-font-name = "FiraCode Nerd Font 9";
          text-scaling-factor = 1.0;
        };
        "org/gtk/gtk4/settings/file-chooser" = {
          sort-directories-first = true;
        };
      };

    };

  perSystem =
    { pkgs, ... }:
    {
      packages.material-black-blueberry-suru = pkgs.stdenvNoCC.mkDerivation {
        pname = "material-black-blueberry-suru-icon-theme";
        version = "unstable-2021-08-16";
        src = pkgs.fetchFromGitHub {
          owner = "rtlewis88";
          repo = "rtl88-Themes";
          rev = "3864d851aac7f4e76cf23717aee104de234aef74";
          hash = "sha256-BUJMd6Ltq16/HqqDbB5VDGIRSzLivXxNYZPT9sd6oTI=";
        };
        nativeBuildInputs = [ pkgs.gtk3 ];
        postPatch = ''
          # assert header exists to fail build loudly if upstream changes
          grep -q '^\[Icon Theme\]' Material-Black-Blueberry-Suru/index.theme
          # add Inherits chain so missing icons gracefully fall back to Papirus-Dark, Adwaita, and hicolor
          sed -i '/^\[Icon Theme\]/a Inherits=Papirus-Dark,Papirus,Adwaita,hicolor' Material-Black-Blueberry-Suru/index.theme
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/icons
          cp -r Material-Black-Blueberry-Suru $out/share/icons/
          runHook postInstall
        '';
      };
    };
}
