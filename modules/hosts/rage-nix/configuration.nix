# rage-nix host configuration
#
#  central system and user composition, host facts, and option assignments for rage-nix
#
# provides:
#   - system: nixosModules.rageConfiguration (composing system leaves + setting rage.* host facts)
#   - user:   homeModules.yuriConfiguration (composing user leaves + setting home facts)
#
# required artifacts:
#   - hardware.nix

{ self, ... }:
{
  flake.nixosModules.rageConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.rageHardware
        self.nixosModules.core
        self.nixosModules.hardware
        self.nixosModules.secrets
        self.nixosModules.niri
        self.nixosModules.apps
        self.nixosModules.appearance
        self.nixosModules.sunshine
        self.nixosModules.bat
        self.nixosModules.btop
        self.nixosModules.fastfetch
        self.nixosModules.starship
        self.nixosModules.storage
        self.nixosModules.nautilus
        self.nixosModules.noctalia
        self.nixosModules.dev
        self.nixosModules.spotify-player
        self.nixosModules.makemkv
        self.nixosModules.media-apps
      ];

      networking.hostName = "rage-nix";
      system.stateVersion = "26.05";

      # Host User Configuration
      rage.niri.autoLoginUser = "yuri";
      rage.secrets.user = "yuri";

      # Network Storage (mount devices are evaluated at build time for /etc/fstab,
      # while passwords and credentials are decrypted at runtime via sops).
      rage.storage = {
        user = "yuri";
        nfsMediaDevice = "pve:/SATA-RAIDZ/media";
        smbShareDevice = "//nfs/share";
        smbCredentialsFile = "/etc/smb-credentials";
      };
      security.sudo.wheelNeedsPassword = false;
      users.users.yuri = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
          "uinput"
          "video"
          "input"
          "render"
          "cdrom"
          "storage"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+xkpNxpSkwJiPIe0dfBXCuj5cbIi5r3W4ypi014oKg yuri@rage"
        ];
      };

      # safe git directory for repository
      programs.git.config.safe.directory = "/home/yuri/nixcfg";
    };

  flake.homeModules.yuriConfiguration =
    { ... }:
    {
      imports = [
        self.homeModules.niri
        self.homeModules.apps
        self.homeModules.appearance
        self.homeModules.noctalia
        self.homeModules.bash
        self.homeModules.foot
        self.homeModules.nvim
        self.homeModules.ssh
        self.homeModules.storage
        self.homeModules.nautilus
        self.homeModules.dev
        self.homeModules.spotify-player
        self.homeModules.media-scripts
      ];

      programs.home-manager.enable = true;
      news.display = "show";

      home.username = "yuri";
      home.homeDirectory = "/home/yuri";
      home.stateVersion = "26.05";
    };
}
