# development Nix flake aggregator
#
#  aggregates all development modules with direct system developer tooling (antigravity-cli, python3)
#
# provides:
#   - system: zed, docker, direnv, antigravity CLI, python3
#   - user:   zed, language-servers, direnv, git, nixcfg-tooling, proxmox-remote, ardupilot
#
# required artifacts:
#   - (none)

{ self, ... }:
{
  flake.nixosModules.dev =
    { pkgs, ... }:
    {
      imports = with self.nixosModules; [
        direnv
        docker
        zed
      ];

      # Direct package inclusion: system-wide developer utilities & Python runtime
      environment.systemPackages = with pkgs; [
        antigravity-cli
        python3
      ];
    };

  flake.homeModules.dev =
    { ... }:
    {
      imports = with self.homeModules; [
        zed
        language-servers
        direnv
        git
        nixcfg-tooling
        proxmox-remote
        ardupilot
      ];
    };
}
