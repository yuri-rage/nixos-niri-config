# ardupilot Nix flake
#
#  ArduPilot development environment integration & dynamic bash completions
#
# provides:
#   - user: PROMPT_COMMAND hook for dynamic direnv completion loading
#
# required artifacts:
#   - ardupilot-completion.sh

{ ... }:
{
  flake.homeModules.ardupilot =
    { ... }:
    {
      programs.bash.initExtra = builtins.readFile ./ardupilot-completion.sh;
    };
}
