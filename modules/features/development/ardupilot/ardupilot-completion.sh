# shellcheck shell=bash
# ArduPilot completion hook (bridges direnv environment with interactive shell)
_ardupilot_direnv_hook() {
  if [ -n "${ARDUPILOT_COMPLETION_SIG:-}" ] && [ "${_LOADED_ARDUPILOT_COMPLETION_SIG:-}" != "$ARDUPILOT_COMPLETION_SIG" ]; then
    if [ -n "${ARDUPILOT_COMPLETION_FILE:-}" ] && [ -f "$ARDUPILOT_COMPLETION_FILE" ]; then
      source "$ARDUPILOT_COMPLETION_FILE"
      _LOADED_ARDUPILOT_COMPLETION_SIG="$ARDUPILOT_COMPLETION_SIG"
    fi
  elif [ -z "${ARDUPILOT_COMPLETION_SIG:-}" ] && [ -n "${_LOADED_ARDUPILOT_COMPLETION_SIG:-}" ]; then
    # Unregister completions and functions defined in Tools/completion/bash/
    complete -r waf sim_vehicle.py autotest.py arducopter arducopter-heli arduplane ardurover ardusub antennatracker 2>/dev/null || true
    unset -f _waf _sim_vehicle _ap_bin _ap_autotest 2>/dev/null || true
    unset _LOADED_ARDUPILOT_COMPLETION_SIG
  fi
}
if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) =~ "declare -a" ]]; then
  PROMPT_COMMAND+=(_ardupilot_direnv_hook)
else
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_ardupilot_direnv_hook"
fi
