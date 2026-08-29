# storage Nix flake
#
#  generic network storage automounts and XDG media directory bindings
#
# provides:
#   - system: configurable NFS and SMB automounts with systemd integration
#   - user:   xdg.userDirs and user-space symlinks into storage pools
#
# required artifacts:
#   - smbCredentialsFile (runtime secret, /etc/smb-credentials via sops)

{ lib, self, ... }:
{
  flake.nixosModules.storage =
    { config, pkgs, ... }:
    let
      cfg = config.rage.storage;
    in
    {
      options.rage.storage = {
        nfsMediaDevice = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Remote NFS media pool export string.";
        };

        smbShareDevice = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Remote SMB/CIFS share path.";
        };

        smbCredentialsFile = lib.mkOption {
          type = lib.types.str;
          default = "/etc/smb-credentials";
          description = "Path to SMB credentials file (must be root-owned 0600).";
        };

        user = lib.mkOption {
          type = lib.types.str;
          example = "yuri";
          description = "Primary user owning storage mount permissions.";
        };
      };

      config = {
        # Filesystem & Storage Utilities (only when SMB is enabled)
        environment.systemPackages = lib.optional (cfg.smbShareDevice != null) pkgs.cifs-utils;

        # Remote automounts
        fileSystems = lib.mkMerge [
          (lib.mkIf (cfg.nfsMediaDevice != null) {
            "/mnt/media" = {
              device = cfg.nfsMediaDevice;
              fsType = "nfs";
              options = [
                "x-systemd.automount"
                "noauto"
                "nofail"
                "x-systemd.idle-timeout=600"
                "x-systemd.device-timeout=5s"
                "x-systemd.mount-timeout=5s"
                "nfsvers=4.2"
                "soft"
                "timeo=14"
                "intr"
              ];
            };
          })

          (lib.mkIf (cfg.smbShareDevice != null) {
            "/mnt/ssd-share" = {
              device = cfg.smbShareDevice;
              fsType = "cifs";
              options = [
                "x-systemd.automount"
                "noauto"
                "nofail"
                "x-systemd.idle-timeout=60"
                "x-systemd.device-timeout=5s"
                "x-systemd.mount-timeout=5s"
                "credentials=${cfg.smbCredentialsFile}"
                "uid=${cfg.user}"
                "gid=users"
                "rw"
                "mfsymlinks"
              ];
            };
          })
        ];
      };
    };

  flake.homeModules.storage =
    {
      config,
      ...
    }:
    {
      imports = [ self.homeModules.common ];

      # XDG Directory Architecture
      xdg.enable = true;
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        pictures = "${config.home.homeDirectory}/Pictures";
        videos = "${config.home.homeDirectory}/Videos";

        extraConfig = {
          XDG_IMPORTS_DIR = "${config.home.homeDirectory}/Videos/Imports";
          XDG_MOVIES_DIR = "${config.home.homeDirectory}/Videos/Movies";
          XDG_TV_DIR = "${config.home.homeDirectory}/Videos/TV";
        };

        # Suppress unused folders
        desktop = null;
        publicShare = null;
        templates = null;
        music = null;
      };

      # Network Media Storage Symlinks
      home.file."ssd-share".source = config.lib.file.mkOutOfStoreSymlink "/mnt/ssd-share";
      home.file."Videos/Imports".source = config.lib.file.mkOutOfStoreSymlink "/mnt/media/Imports";
      home.file."Videos/Movies".source = config.lib.file.mkOutOfStoreSymlink "/mnt/media/Movies";
      home.file."Videos/TV".source = config.lib.file.mkOutOfStoreSymlink "/mnt/media/TV";
    };
}
