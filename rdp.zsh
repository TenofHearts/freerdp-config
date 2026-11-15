# Shared defaults; override this array in ~/.zshrc.local.
typeset -ga RDP_FLAGS
RDP_FLAGS=(/f +clipboard +dynamic-resolution +auto-reconnect +grab-keyboard)

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
