#!/bin/sh
set -eu
if systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user daemon-reload
fi
