# nixcfg-tooling Nix flake
#
#  repository management tooling and 'j' wrapper functions
#
# provides:
#   - user: just, complete-j.sh bash completions, and 'j' global recipe alias
#
# required artifacts:
#   - complete-j.sh

{ ... }:
{
  flake.homeModules.nixcfg-tooling =
    {
      config,
      link,
      pkgs,
      self,
      ...
    }:
    {
      imports = [ self.homeModules.common ];
      home.packages = with pkgs; [
        just
        jq
      ];
      xdg.configFile."just/justfile".source = link "justfile";
      programs.bash.shellAliases.j = "just -g";
      programs.bash.initExtra = builtins.replaceStrings [ "@REPO@" ] [ config.rage.repoPath ] (
        builtins.readFile ./complete-j.sh
      );
    };
}
