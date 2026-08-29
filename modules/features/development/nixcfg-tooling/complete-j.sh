# Global autocompletion for 'j' (just -g) alias
_complete_j() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ $COMP_CWORD -eq 1 ]]; then
    local recipes
    recipes=$(just -g --summary 2>/dev/null)
    COMPREPLY=( $(compgen -W "$recipes" -- "$cur") )
    return 0
  fi

  if [[ "$prev" == "update" || "$prev" == "update-switch" ]]; then
    local inputs
    inputs=$(jq -r '.nodes.root.inputs | keys[]' @REPO@/flake.lock 2>/dev/null)
    COMPREPLY=( $(compgen -W "$inputs" -- "$cur") )
    return 0
  fi

  if [[ "$prev" == "gc" ]]; then
    COMPREPLY=( $(compgen -W "all 7d 10d 14d 30d" -- "$cur") )
    return 0
  fi
}
complete -F _complete_j j
