# Shared defaults; override this array in ~/.zshrc.local.
typeset -ga RDP_FLAGS
RDP_FLAGS=(
  /dynamic-resolution
  /grab-keyboard
  /sound
  /microphone
  +clipboard
  /drive:MacShare,"$HOME/Downloads"
  +auto-reconnect
)

# Saved connections are ordinary .rdp files, kept outside the dotfiles repo.
rdp() {
  local profile_dir=${RDP_PROFILE_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/freerdp/connections}
  local target=${1:-} selected
  local -a profiles
  if [[ $target == --help || $target == -h ]]; then
    print -r -- 'Usage: rdp [saved-name | host[:port] | file.rdp] [FreeRDP options...]'
    print -r -- "Saved connections: $profile_dir/*.rdp"
    print -r -- 'Without a target, select a saved connection with fzf.'
    return
  fi
  if [[ $target == --list ]]; then
    profiles=("$profile_dir"/*.rdp(N:t:r))
    (( ${#profiles} )) && print -rl -- "${profiles[@]}"
    return 0
  fi
  if [[ -z $target ]]; then
    profiles=("$profile_dir"/*.rdp(N:t:r))
    if (( ! ${#profiles} )); then
      print -u2 -r -- "No saved connections. Add .rdp files to $profile_dir"
      return 1
    fi
    if (( ! $+commands[fzf] )); then
      print -u2 -- 'fzf is required for the picker; use rdp <saved-name> instead.'
      return 1
    fi
    selected=$(print -rl -- "${profiles[@]}" | command fzf --prompt='RDP machine> ') || return
    target=$profile_dir/$selected.rdp
  else
    shift
    if [[ -f $profile_dir/$target.rdp ]]; then
      target=$profile_dir/$target.rdp
    fi
  fi
  if [[ -f $target ]]; then
    command sdl-freerdp "$target" "${RDP_FLAGS[@]}" "$@"
  elif [[ $target == *.rdp ]]; then
    print -u2 -r -- "Connection file not found: $target"
    return 1
  else
    command sdl-freerdp "/v:$target" "${RDP_FLAGS[@]}" "$@"
  fi
}

# Run in a subshell so umask and noclobber stay local to this operation.
rdp-add() (
  local profile_dir=${RDP_PROFILE_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/freerdp/connections}
  local name address username domain target
  if (( $# )); then
    print -r -- 'Usage: rdp-add (interactively save a named RDP connection)'
    return 0
  fi
  read -r 'name?Connection name (e.g. office-pc): ' || return 1
  if [[ -z $name || $name != [a-zA-Z0-9]* || $name == *[^a-zA-Z0-9._-]* ]]; then
    print -u2 -- 'Use letters, numbers, dots, underscores, or hyphens; start with a letter or number.'
    return 1
  fi
  target=$profile_dir/$name.rdp
  if [[ -e $target || -L $target ]]; then
    print -u2 -r -- "Connection already exists: $target"
    return 1
  fi
  read -r 'address?Host address (optionally :port): ' || return 1
  read -r 'username?Username (DOMAIN\user is also accepted): ' || return 1
  read -r 'domain?Domain (optional; Enter to skip): ' || return 1
  if [[ -z $address || -z $username || $address == *[[:space:]]* ||
        $username == *$'\r'* || $domain == *$'\r'* ]]; then
    print -u2 -- 'An address without whitespace and a username are required; carriage returns are not allowed.'
    return 1
  fi
  umask 077
  mkdir -p -- "$profile_dir" || return 1
  setopt noclobber
  {
    print -r -- "full address:s:$address"
    print -r -- "username:s:$username"
    print -r -- "domain:s:$domain"
    print -r -- 'screen mode id:i:2'
    print -r -- 'dynamic resolution:i:1'
    print -r -- 'redirectclipboard:i:1'
    print -r -- 'keyboardhook:i:1'
  } > "$target" || return 1
  print -r -- "Saved $target"
  print -r -- "Connect with: rdp $name"
)
