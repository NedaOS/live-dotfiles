#!/bin/sh
# Retire only the obsolete login capture service; never start/stop the desktop.
set -eu
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
link="$unit_dir/default.target.wants/chezmoi-auto-sync.service"
# Also handle partially applied migrations where the unit is already masked.
if [ -L "$link" ]; then
    case "$(readlink "$link")" in
        "$unit_dir/chezmoi-auto-sync.service"|../chezmoi-auto-sync.service)
            rm -- "$link" ;;
        *) echo "Unexpected Auto-Sync enablement link; inspect manually: $link" >&2; exit 1 ;;
    esac
fi
if systemctl --user show-environment >/dev/null 2>&1; then
    if systemctl --user is-enabled --quiet chezmoi-auto-sync.service; then
        systemctl --user disable chezmoi-auto-sync.service
    fi
fi
