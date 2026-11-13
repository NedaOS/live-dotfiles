# Workstation dotfiles

Ansible owns packages, privileged configuration, system services, greetd and
Noctalia Greeter. Chezmoi owns intentional user preferences, Hyprland Lua,
user scripts and Noctalia templates. Noctalia owns generated Kitty/Fish/Hyprland
palettes, wallpaper state and GUI settings. Its Greeter Auto-Sync stays enabled;
it is unrelated to the retired Chezmoi login capture service.

The old user service is disabled during apply and persistently masked. The
compatibility command `chezmoi-auto-sync` now runs only `chezmoi status` and
rejects arguments (including `push`). There is no replacement background service.
No source capture, forgetting, staging, commits or pushes happen at login.

## Review and apply

```sh
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

To intentionally import one reviewed change, use `chezmoi add PATH` for a new
file or `chezmoi re-add PATH` for a managed file. Review templates before re-add:
it can replace deliberate templating. For deletions/renames, explicitly review
both source and target; no automatic forgetting occurs.
Then inspect `git -C ~/.local/share/chezmoi diff`, stage explicit paths and commit
manually. Review the staged diff before committing; pushing is always manual.
Never bulk re-add, add runtime directories, credentials, tokens or caches.
Do not enable Chezmoi's optional Git autoadd/autocommit/autopush settings.

Generated palettes and Fish universal variables were removed from source only;
live copies survive application. Ignore rules keep them outside Chezmoi ownership.
Fish fnm integration is managed here; Ansible installs the executable. Paths use
Chezmoi's homeDir template. A fresh Hyprland session uses fallback border colors
until Noctalia generates its palette; Kitty accepts a missing generated theme.
Keep the Noctalia template inputs and output routing files managed here.

Existing picture assets remain unchanged pending an explicit privacy/ownership
decision. In particular Pictures/nedamani-1.png and wallpaper/fastfetch images
have not been inspected. Review their suitability before publishing; removal
from Git history is a separate decision. No private variable contents were read.

## Diagnose and recover

```sh
systemctl --user is-enabled chezmoi-auto-sync.service  # masked
systemctl --user list-timers --all
~/.config/hypr/scripts/preflight.sh
noctalia config validate
pgrep -ax kdeconnectd
```

Run `chezmoi diff` locally to inspect intentional-file drift. Generated state is
intentionally absent from this report. If colors stop updating, inspect
`~/.config/noctalia/templates.toml` and `hyprland-colors.toml`, their referenced
template inputs and Noctalia's log; do not re-add generated outputs. To restore
an intentional file, preview then apply that exact path with Chezmoi.
For graphical login recovery see the Ansible repository's
`docs/noctalia-greeter.md` (TTY, repair greetd, restore contexts and alias).
Apply does not restart greetd or your session. Logout/reboot testing is manual.

Run isolated regression tests with `python3 -m unittest discover -s tests -v`.
