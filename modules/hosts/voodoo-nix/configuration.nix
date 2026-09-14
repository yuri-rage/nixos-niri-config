# voodoo-nix host configuration
#
#  central system and user composition, host facts, and option assignments for voodoo-nix (WSL2)
#
# provides:
#   - system: nixosModules.voodooConfiguration
#   - user:   homeModules.yuriWslConfiguration
#
# required artifacts:
#   - (none)

{ self, inputs, ... }:
{
  flake.nixosModules.voodooConfiguration =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.nixos-wsl.nixosModules.default
        self.nixosModules.core
        self.nixosModules.bat
        self.nixosModules.btop
        self.nixosModules.fastfetch
        self.nixosModules.starship
        self.nixosModules.dev
        self.nixosModules.secrets
      ];

      # Secrets user configuration
      rage.secrets.user = "yuri";

      # WSL Integration
      wsl = {
        enable = true;
        defaultUser = "yuri";
        wslConf.network.hostname = "voodoo-nix";
      };

      networking.hostName = "voodoo-nix";
      system.stateVersion = "26.05";

      # Disable bare-metal/non-WSL services brought in by core
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
      networking.networkmanager.enable = lib.mkForce false;
      services.printing.enable = lib.mkForce false;
      services.avahi.enable = lib.mkForce false;
      zramSwap.enable = lib.mkForce false;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # User configuration
      security.sudo.wheelNeedsPassword = false;
      users.users.yuri = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
        ];
      };

      # Provide home-manager CLI in systemPackages
      environment.systemPackages = [
        inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      # Safe git directory for repository
      programs.git.config.safe.directory = "/home/yuri/nixcfg";
    };

  flake.homeModules.yuriWslConfiguration =
    { ... }:
    {
      imports = [
        self.homeModules.bash
        self.homeModules.nvim
        self.homeModules.ssh
        self.homeModules.dev
      ];

      programs.home-manager.enable = true;
      news.display = "show";

      home.username = "yuri";
      home.homeDirectory = "/home/yuri";
      home.stateVersion = "26.05";
    };
}
