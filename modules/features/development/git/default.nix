# git Nix flake
#
#  distributed version control client and productivity aliases
#
# provides:
#   - user: programs.git with aliases and diff/log utilities
#
# required artifacts:
#   - (none)
#
# aliases:
#   - git amend   = "commit --amend --no-edit"
#   - git lg      = "log --graph --pretty=format:'...' --abbrev-commit"
#   - git st      = "status -sb"
#   - git unstage = "restore --staged"
#   - glog        = "git log --oneline"
#   - gcom        = "git add . && git commit -m"

{ ... }:
{
  flake.homeModules.git =
    { ... }:
    {
      programs.git = {
        enable = true;
        ignores = [
          ".envrc"
          ".direnv"
          ".direnv/"
        ];
        settings = {
          user = {
            name = "Yuri Rage";
            email = "yuri-rage@users.noreply.github.com";
          };
          init = {
            defaultBranch = "master";
          };
          safe = {
            directory = "/home/yuri/nixcfg";
          };
          alias = {
            amend = "commit --amend --no-edit";
            lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            st = "status -sb";
            unstage = "restore --staged";
          };
        };
      };

      home.shellAliases = {
        glog = "git log --oneline";
        gcom = "git add . && git commit -m";
      };
    };
}
