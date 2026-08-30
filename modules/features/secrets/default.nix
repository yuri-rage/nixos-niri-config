# secrets Nix flake
#
#  declarative secrets management via sops-nix
#
# provides:
#   - system: sops decryption for smb-credentials, user ssh-hosts, and user docker-config
#
# required artifacts:
#   - secrets/secrets.yaml
#   - .sops.yaml (root encryption policy)
#
# bootstrap lifecycle on fresh hardware:
#   1. Generate/inspect new host key: cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
#   2. Add new recipient age key to .sops.yaml
#   3. Re-encrypt from admin machine with user age key: sops updatekeys secrets/secrets.yaml
#   4. Run 'just switch'

{
  inputs,
  lib,
  self,
  ...
}:
{
  flake.nixosModules.secrets =
    { config, ... }:
    let
      cfg = config.rage.secrets;
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      options.rage.secrets = {
        user = lib.mkOption {
          type = lib.types.str;
          example = "yuri";
          description = "Primary user account owning decrypted user secrets.";
        };
      };

      config = {
        sops = {
          defaultSopsFile = self + "/secrets/secrets.yaml";
          defaultSopsFormat = "yaml";
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          secrets = {
            smb-credentials = {
              path = "/etc/smb-credentials";
              mode = "0600";
            };
            ssh-hosts = {
              path = "/home/${cfg.user}/.config/ssh/hosts.conf";
              owner = cfg.user;
              group = "users";
              mode = "0600";
            };
            docker-config = {
              path = "/home/${cfg.user}/.docker/config.json";
              owner = cfg.user;
              group = "users";
              mode = "0600";
            };
          };
        };
      };
    };
}
