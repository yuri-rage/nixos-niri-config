# bash Nix flake
#
#  interactive Bash shell environment, shell utilities, and completion
#
# provides:
#   - user: programs.bash with extract(), whatsmyip(), fastfetch banner, and directory history
#
# required artifacts:
#   - initExtra.sh

{ self, ... }:
{
  flake.homeModules.bash =
    { pkgs, ... }:
    {
      imports = [ self.homeModules.common ];

      home.packages = with pkgs; [
        # utilities required by aliases
        git
        trash-cli

        # additional utils
        fastfetch
        curl
        psmisc
        wget

        # archive extractors for extract()
        p7zip
        unrar
        unzip
        bzip2
      ];

      # integrations used in aliases and readline bindings
      programs.fzf.enable = true;
      programs.ripgrep.enable = true;
      programs.zoxide.enable = true;

      programs.eza = {
        enable = true;
        enableBashIntegration = true;
        icons = "auto";
        git = true;
      };

      programs.bash = {
        enable = true;

        # custom shell functions
        initExtra = builtins.readFile ./init-extra.sh;

        shellAliases = {
          # safety flags
          cp = "cp -i";
          mv = "mv -i";
          mkdir = "mkdir -p";
          rm = "trash -v";
          rmd = "command rm -rfv";

          # navigation
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";

          # system monitoring / tools
          openports = "ss -tulpn"; # modern replacement for netstat
          mountedinfo = "df -hT";
          da = "date \"+%Y-%m-%d %A %T %Z\"";
          cls = "clear";
          tree = "eza --tree";
          tree2 = "eza --tree --level=2";
          treed = "eza --tree -D";
        };
      };
    };
}
