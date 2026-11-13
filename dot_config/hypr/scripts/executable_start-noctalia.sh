#!/bin/sh
# Start Noctalia exactly once.
# - Inside a uwsm-managed session it runs as a uwsm app.
# - Otherwise it is started directly ("Hyprland (Quiet)" session).
# Log: ~/.cache/noctalia/noctalia.log (written by Noctalia itself).

command -v noctalia >/dev/null 2>&1 || { echo "noctalia not installed" >&2; exit 1; }

if pgrep -x noctalia >/dev/null 2>&1; then
    exit 0
fi

if command -v uwsm >/dev/null 2>&1 && uwsm check is-active >/dev/null 2>&1; then
    exec uwsm app -- noctalia
fi

exec noctalia
