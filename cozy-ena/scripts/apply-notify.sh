#!/usr/bin/env bash
# Plasma toast corner: default top-right (no KWin hacks)
set -euo pipefail
kwriteconfig6 --file plasmanotifyrc --group Notifications --key PopupPosition TopRight
# ensure toast-lower KWin script stays off if leftover
kwriteconfig6 --file kwinrc --group Plugins --key cozyena-notify-lowerEnabled false
qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript cozyena-notify-lower 2>/dev/null || true
echo "Notifications: PopupPosition=TopRight"
