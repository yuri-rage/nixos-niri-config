# proxmox-remote Nix flake
#
#  Proxmox VE administrative remote utilities
#
# provides:
#   - user: pve-update-lxcs shell alias
#
# required artifacts:
#   - (none)
#
# external dependencies:
#   - pve SSH host definition

{ ... }:
{
  flake.homeModules.proxmox-remote =
    { ... }:
    {
      programs.bash.shellAliases = {
        pve-update-lxcs = "ssh pve update-lxcs";
      };
    };
}
