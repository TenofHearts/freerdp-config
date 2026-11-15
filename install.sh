#!/usr/bin/env sh
# Portable user configuration installer for Linux and macOS.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
dest=${XDG_CONFIG_HOME:-$HOME/.config}/freerdp
mkdir -p "$dest/connections"
for name in sdl-freerdp.json rdp.zsh connection.rdp.example; do
    target=$dest/$name
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$root/$name" ]; then
        continue
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        printf 'Keeping existing configuration: %s\n' "$target"
        continue
    fi
    ln -s "$root/$name" "$target"
    printf 'Linked %s\n' "$target"
done
printf '%s\n' 'For optional Zsh shortcuts, add to .zshrc:' 'source "${XDG_CONFIG_HOME:-$HOME/.config}/freerdp/rdp.zsh"'
