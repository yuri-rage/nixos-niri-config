# typst Nix flake
#
#  system-wide typst typesetting toolchain with compiler, LSP (tinymist), and formatter (typstyle)
#
# provides:
#   - system: corefonts, vista-fonts, typst, tinymist, typstyle
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.typst =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        typst # Markup-based typesetting compiler
        tinymist # Integrated language server protocol (LSP) for Typst
        typstyle # Fast, beautiful, and opinionated code formatter for Typst
      ];

      fonts.packages = with pkgs; [
        corefonts # Microsoft core fonts (Arial, Times New Roman, etc)
        vista-fonts # Calibri, Cambria, Consolas, etc
      ];
    };
}
