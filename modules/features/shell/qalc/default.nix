# qalc Nix flake
#
#  interactive scientific and unit-converting CLI calculator (libqalculate)
#
# provides:
#   - system: libqalculate (qalc CLI)
#   - user:   daily qalc exchange rate update timer
#
# required artifacts:
#   - (none)

{ ... }:
{
  flake.nixosModules.qalc =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        libqalculate
      ];
    };

  flake.homeModules.qalc =
    { pkgs, ... }:
    {
      systemd.user.services.qalc-exrates = {
        Unit = {
          Description = "Update libqalculate exchange rates";
          After = [ "network-online.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.libqalculate}/bin/qalc --exrates quit";
        };
      };

      systemd.user.timers.qalc-exrates = {
        Unit.Description = "Daily libqalculate exchange rate update";
        Timer = {
          OnCalendar = "daily";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
