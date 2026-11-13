#!/bin/sh
# Install this configuration into ~/.config/hypr (after a full backup).
# Does NOT restart Hyprland, greetd or the computer. Running Hyprland reloads the
# config by itself when files change; Noctalia starts on the next login
# (or run scripts/start-noctalia.sh to start it now).
set -eu
SRC="$(cd "$(dirname "$0")/.." && pwd)"
DST="$HOME/.config/hypr"
STAMP="$(date +%F-%H%M%S)"
BK="$HOME/.config/hypr.backup-$STAMP"

[ "$SRC" != "$DST" ] || { echo "Run this from the unpacked hypr-new folder, not from ~/.config/hypr."; exit 1; }

mkdir -p "$DST"
cp -a "$DST" "$BK"
echo "Backup: $BK"

# Everything first, hyprland.lua LAST, so a live reload never sees a half-installed tree.
mkdir -p "$DST/config" "$DST/scripts"
cp -a "$SRC/config/." "$DST/config/"
cp -a "$SRC/scripts/." "$DST/scripts/"
chmod +x "$DST"/scripts/*.sh
cp -a "$SRC/hyprland.lua" "$DST/hyprland.lua"

echo "Installed to $DST"
echo "Legacy files that are no longer loaded (left in place, also in the backup):"
for f in "$DST"/*; do
    case "$(basename "$f")" in hyprland.lua|config|scripts) ;; *) echo "  $f";; esac
done
echo
echo "Check for errors now:   hyprctl configerrors"
echo "Roll back if needed:    $DST/scripts/rollback.sh"
