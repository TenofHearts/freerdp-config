# FreeRDP configuration

Standalone SDL FreeRDP configuration for Linux and macOS.
Install FreeRDP with its SDL client (`sdl-freerdp`) using your package manager.
The optional machine picker uses `fzf`.

This repository supplies configuration and shell functions only. The parent
dotfiles project owns dependency installation, linking, and shell setup.
Link these files individually into `${XDG_CONFIG_HOME:-~/.config}/freerdp`:

- `sdl-freerdp.json` — SDL client preferences.
- `rdp.zsh` — optional Zsh connection functions and default flags.
- `connection.rdp.example` — template for machine-local connections.
The JSON configuration is loaded by SDL FreeRDP directly; no shell function
is needed for its scroll setting. Close and relaunch the client after changes.

For optional Zsh shortcuts, add this to `.zshrc`, then reload Zsh:

```zsh
source "${XDG_CONFIG_HOME:-$HOME/.config}/freerdp/rdp.zsh"
```

`rdp` uses `RDP_BIN` as the executable name or path. It defaults to
`sdl-freerdp` (Homebrew); on CachyOS, set `export RDP_BIN=sdl-freerdp3`
in your platform's `.zshrc`. Put command-line options in `RDP_FLAGS`, not `RDP_BIN`.

When used as a submodule of the macOS dotfiles, `./install.sh --only freerdp`
from the parent repository initializes this submodule and installs the links.

```sh
rdp-add                          # Add a saved host interactively
rdp workstation                  # Saved connection
rdp                              # fzf picker of saved connections
rdp --list                       # List saved names
rdp 192.0.2.10 /u:your-user       # Direct connection
rdp workstation -f               # Override fullscreen for this launch
```

Defaults: `/dynamic-resolution /grab-keyboard /sound /microphone +clipboard /drive:MacShare,"$HOME/Downloads" +auto-reconnect`.
The Downloads directory is shared as `MacShare`.
Override them after sourcing `rdp.zsh` (or in the dotfiles' `~/.zshrc.local`) using a Zsh array, for example:

```zsh
RDP_FLAGS=(/dynamic-resolution /grab-keyboard /sound /microphone +clipboard /drive:MacShare,"$HOME/Downloads" +auto-reconnect /f)
```

## Add a host interactively

After loading `rdp.zsh`, run `rdp-add` without arguments:

```text
% rdp-add
Connection name (e.g. office-pc): office-pc
Host address (optionally :port): 192.0.2.10:3389
Username (DOMAIN\user is also accepted): CONTOSO\alice
Domain (optional; Enter to skip):
```

The connection name becomes the filename, without needing to enter `.rdp`.
Names must start with a letter or number and may contain letters, numbers,
dots, underscores, and hyphens. Enter a hostname or IP address, optionally
including a port. Usernames are saved literally, including backslashes.
If the username already includes its domain, leave the separate domain empty.

The function saves `office-pc.rdp` in
`${RDP_PROFILE_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/freerdp/connections}`,
creating the directory if necessary. Connect with `rdp office-pc`, or run `rdp`
to pick it from the saved hosts.

New profiles enable fullscreen, dynamic resolution, clipboard sharing, and
remote Windows keyboard shortcuts (`keyboardhook:i:1`).
Files have owner-only permissions (`0600`); existing names are never overwritten.
Passwords are not requested or stored. Cancel with Ctrl-C; incomplete input
is not saved.

## Add a host manually

Or create a saved connection manually:

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

## Local connection data

Personal `.rdp` profiles and passwords are not tracked in this repository.
The parent dotfiles project should link individual files so existing FreeRDP
certificates, connection profiles, and other runtime data remain local.
