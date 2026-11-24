# FreeRDP connections

The [parent dotfiles](https://github.com/TenofHearts/dotfiles) load these SDL
FreeRDP commands in Zsh:

```zsh
rdp-add                   # Save a host interactively
rdp workstation           # Connect by saved name
rdp                       # Pick a saved host with fzf
rdp --list                # List saved names without fzf
rdp 192.0.2.10 /u:alice   # Connect directly; put client options after the host
```

`rdp-add` saves owner-only `.rdp` files under `${XDG_CONFIG_HOME:-$HOME/.config}/freerdp/connections`.
Set `RDP_PROFILE_DIR` to use a different directory. Existing names are never
overwritten. Keep profiles local and let the client prompt for passwords.

## Local overrides

`RDP_BIN` takes an executable name or path. The wrapper defaults to `sdl-freerdp`;
the CachyOS dotfiles select `sdl-freerdp3`. Put client options in the `RDP_FLAGS`
Zsh array in `~/.zshrc.local`.

**Sharing defaults:** The remote host gets clipboard access, microphone input,
and `~/Downloads` as a drive named `MacShare`. To restrict sharing, review both
`RDP_FLAGS` and the redirection settings in the saved `.rdp` file.
