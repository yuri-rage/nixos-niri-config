# ssh Nix flake
#
#  declarative SSH client configuration with sops-managed host inventory
#
# provides:
#   - user: programs.ssh with ~/.config/ssh/hosts.conf include
#
# required artifacts:
#   - ~/.config/ssh/hosts.conf (runtime secret via sops-nix)

{ self, ... }:
{
  flake.homeModules.ssh =
    { ... }:
    {
      imports = [ self.homeModules.common ];

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [
          "~/.config/ssh/hosts.conf"
        ];
      };
    };
}
