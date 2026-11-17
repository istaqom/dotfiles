#!/usr/bin/env bash
# Plasma toast corner: bottom-right (Steam/libnotify follow this too)
set -euo pipefail
kwriteconfig6 --file plasmanotifyrc --group Notifications --key PopupPosition BottomRight
echo "Notifications: PopupPosition=BottomRight"
