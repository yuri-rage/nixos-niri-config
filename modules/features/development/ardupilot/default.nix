# ardupilot Nix flake
#
#  ArduPilot development environment integration & dynamic bash completions
#
# provides:
#   - system: firewall rule for inbound MAVLink UDP (14550 GCS broadcast)
#   - user:   PROMPT_COMMAND hook for dynamic direnv completion loading
#
# required artifacts:
#   - ardupilot-completion.sh

{ ... }:
{
  flake.nixosModules.ardupilot =
    { ... }:
    {
      # MAVLink telemetry broadcast to ground control stations (vehicles, SITL, mavproxy --out)
      networking.firewall.allowedUDPPorts = [ 14550 ];
    };

  flake.homeModules.ardupilot =
    { ... }:
    {
      programs.bash.initExtra = builtins.readFile ./ardupilot-completion.sh;
    };
}
