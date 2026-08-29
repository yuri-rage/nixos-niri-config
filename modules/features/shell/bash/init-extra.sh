# shellcheck shell=bash
# Universal archive extractor
extract() {
  for archive in "$@"; do
    if [ -f "$archive" ]; then
      case "$archive" in
        *.tar.bz2) tar xvjf "$archive" ;;
        *.tar.gz)  tar xvzf "$archive" ;;
        *.bz2)     bunzip2 "$archive" ;;
        *.rar)     unrar x "$archive" ;;
        *.gz)      gunzip "$archive" ;;
        *.tar)     tar xvf "$archive" ;;
        *.tbz2)    tar xvjf "$archive" ;;
        *.tgz)     tar xvzf "$archive" ;;
        *.zip)     unzip "$archive" ;;
        *.Z)       uncompress "$archive" ;;
        *.7z)      7z x "$archive" ;;
        *)         echo "Unknown archive format: '$archive'" ;;
      esac
    else
      echo "'$archive' is not a valid file!"
    fi
  done
}

# Detached process runner
rr() { nohup "$@" > /dev/null 2>&1 & }

# Multi-Interface IP & WAN Lookup
whatsmyip() {
  ip -br addr show | awk '$1 !~ /^lo/ && $3 != "" {print $1 ": " $3}'
  echo -n "WAN: " && curl -s ifconfig.me && echo
}

# Readline Quality-of-Life
if [[ $- == *i* ]]; then
  bind "set bell-style none"
  bind "set completion-ignore-case on"     # Case-insensitive tab completion
  bind "set show-all-if-ambiguous on"      # Show completions on single tab
  bind '"\C-f":"zi\n"'                     # Ctrl+F launches zoxide interactive fuzzy find
fi

# Auto fastfetch on interactive shell startup
if [[ $- == *i* && -z "$NVIM" && -z "$ZED_TERM" ]]; then
  fastfetch
fi

