# btop Nix flake
#
#  system resource monitor with custom themes and persistent configuration
#
# provides:
#   - system: programs.btop with btop.conf and themes + 'top'/'htop' aliases
#
# required artifacts:
#   - btop.conf
#   - themes/

{ ... }:
{
  flake.nixosModules.btop =
    { pkgs, ... }:
    let
      btopWrapped = pkgs.symlinkJoin {
        name = "btop-${pkgs.btop.version}";
        paths = [ pkgs.btop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        meta = pkgs.btop.meta // {
          mainProgram = "btop";
        };
        postBuild = ''
          wrapProgram $out/bin/btop \
            --add-flags "--config /etc/xdg/btop/btop.conf --themes-dir /etc/xdg/btop/themes"
        '';
      };
    in
    {
      environment.systemPackages = [ btopWrapped ];

      environment.etc = {
        "xdg/btop/btop.conf".source = ./btop.conf;
        "xdg/btop/themes".source = ./themes;
      };

      environment.shellAliases = {
        top = "btop";
        htop = "btop";
      };
    };
}
