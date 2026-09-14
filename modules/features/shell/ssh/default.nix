# ssh Nix flake
#
#  declarative SSH client configuration with sops-managed host inventory
#
# provides:
#   - user: programs.ssh with ~/.config/ssh/hosts.conf include, waypipe
#
# required artifacts:
#   - ~/.config/ssh/hosts.conf (runtime secret via sops-nix)

{ self, ... }:
{
  flake.homeModules.ssh =
    { pkgs, ... }:
    {
      imports = [ self.homeModules.common ];

      home.packages = [ pkgs.waypipe ];

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [
          "~/.config/ssh/hosts.conf"
        ];
      };
    };
}
