# lib Nix flake
#
#  global repository helper functions and out-of-store link generator
#
# provides:
#   - options:          rage.repoPath
#   - module arguments: link (mkOutOfStoreSymlink helper relative to rage.repoPath)
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.homeModules.common =
    { config, lib, ... }:
    {
      key = "flake.homeModules.common";

      options.rage.repoPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/nixcfg";
        description = "Path to the nix configuration repository for out-of-store symlinks.";
      };

      config._module.args.link =
        path: config.lib.file.mkOutOfStoreSymlink "${config.rage.repoPath}/${path}";
    };
}
