# FreeRDP configuration

Standalone SDL FreeRDP configuration for Linux and macOS.
Install FreeRDP with its SDL client (`sdl-freerdp`) using your package manager;
on macOS use `brew install freerdp`. The optional machine picker uses `fzf`.

Run `./install.sh` from this repository to link the shared configuration into
`${XDG_CONFIG_HOME:-~/.config}/freerdp`. Existing files are preserved.
The JSON configuration is loaded by SDL FreeRDP directly; no shell function
is needed for its scroll setting. Close and relaunch the client after changes.

For optional Zsh shortcuts, add this to `.zshrc`, then reload Zsh:

```zsh
source "${XDG_CONFIG_HOME:-$HOME/.config}/freerdp/rdp.zsh"
```

When used as a submodule of the macOS dotfiles, `./install.sh --only freerdp`
from the parent repository installs the links instead.

```sh
rdp workstation                  # Saved connection
rdp                              # fzf picker of saved connections
rdp --list                       # List saved names
rdp 192.0.2.10 /u:your-user       # Direct connection
rdp workstation -f               # Override fullscreen for this launch
```

Defaults: `/f +clipboard +dynamic-resolution +auto-reconnect +grab-keyboard`.
Override them after sourcing `rdp.zsh` (or in the macOS dotfiles' `~/.zshrc.local`) using a Zsh array, for example:

```zsh
RDP_FLAGS=(/f +clipboard +dynamic-resolution +auto-reconnect +grab-keyboard /sound)
```

Create a saved connection:

```sh
mkdir -p ~/.config/freerdp/connections
cp ~/.config/freerdp/connection.rdp.example ~/.config/freerdp/connections/workstation.rdp
```

The filename is the familiar host name: `workstation.rdp` becomes `rdp workstation`.
Use any name you like, such as `office-pc.rdp` or `home-server.rdp`.

Edit its address, username, and optional domain. You can also place existing
`.rdp` files in that directory. `RDP_PROFILE_DIR` overrides the directory;
otherwise it follows `XDG_CONFIG_HOME`. Connection files remain machine-local.
Passwords are prompted by FreeRDP; saving a profile does not save credentials.
Reconnecting to the same Windows user normally resumes its existing session,
subject to server policy. `+auto-reconnect` handles interruptions during a run;
it does not provide passwordless login on subsequent launches.

Use `/f` to start fullscreen; the installed SDL client's default local shortcut
is Right Shift + Return to toggle fullscreen (see `sdl-freerdp /help`).

## Trackpad scrolling

`sdl-freerdp.json` enables `UseLocalMouseScrollDirection` to use the local
scroll direction rather than SDL FreeRDP's default normalization. Relaunch the
client after changing it. This applies only to SDL FreeRDP and does not require
the shell helper. It affects both scroll axes; non-natural wheel events are
unaffected by this setting.

## Local connection data

Personal `.rdp` profiles and passwords are not tracked in this repository.
The installer links individual files so existing FreeRDP certificates,
connection profiles, and other runtime data remain local.
