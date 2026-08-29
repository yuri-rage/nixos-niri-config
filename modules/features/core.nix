# core Nix flake
#
#  foundational system services, bootloader defaults, localization, and nix settings
#
# provides:
#   - system: systemd-boot, zramSwap, nix flakes/gc, and system-wide core packages
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.core =
    { ... }:
    {
      # Bootloader
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 15;
      };
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.timeout = 10;

      # Localization & Timezone
      time.timeZone = "America/Chicago";
      i18n.defaultLocale = "en_US.UTF-8";

      # Memory & Zram
      zramSwap.enable = true;
      zramSwap.memoryPercent = 50;

      # Nix Package Manager & Store Optimization
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.auto-optimise-store = false;
      nix.optimise.automatic = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 10d";
      };
      nixpkgs.config.allowUnfree = true;

      # Dynamic Linker stub for precompiled Linux binaries (Zed language servers, Mason, etc.)
      programs.nix-ld.enable = true;

      # Essential System Services
      services.printing.enable = true;
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
        };
      };

      # Networking
      networking.networkmanager.enable = true;

      # System-wide Editor & Environment
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      programs.git.enable = true;
    };
}
