# flake-options Nix flake
#
#  top-level flake option declarations and tree formatting
#
# provides:
#   - options:   flake.homeModules option definition
#   - perSystem: formatter (nixfmt-tree)
#
# required artifacts:
#   - (none)

{ lib, ... }:
{
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
    description = "Home Manager modules exported by this flake.";
  };

  config.systems = [ "x86_64-linux" ];

  config.perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
    };
}
