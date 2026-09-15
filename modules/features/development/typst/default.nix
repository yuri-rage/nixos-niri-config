# typst Nix flake
#
#  system-wide typst typesetting toolchain with compiler, LSP (tinymist), and formatter (typstyle)
#
# provides:
#   - system: typst, tinymist, typstyle
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
    };
}
