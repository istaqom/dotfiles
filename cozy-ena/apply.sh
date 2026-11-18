#!/usr/bin/env bash
# Apply Cozy Ena Plasma rice
set -euo pipefail
ROOT="$(cd "$(dirname "$0") && pwd)"
export PATH="/usr/bin:/bin:/usr/local/bin:${HOME}/.local/bin:${PATH:-}"

echo "== Cozy Ena apply =="
"$ROOT/scripts/backup.sh"
"$ROOT/scripts/apply-fonts.sh"
"$ROOT/scripts/apply-icons.sh"
"$ROOT/scripts/apply-plasma-theme.sh"
"$ROOT/scripts/apply-lockscreen.sh"
"$ROOT/scripts/apply-panels.sh"
"$ROOT/scripts/apply-bigclock-pos.sh"
"$ROOT/scripts/apply-mediadock.sh"
"$ROOT/scripts/apply-splash.sh"
"$ROOT/scripts/apply-notify.sh"
"$ROOT/scripts/apply-bitwarden-tray.sh"

echo
echo "Done. If panels look stale: systemctl --user restart plasma-plasmashell.service"
echo "Restart Discord/Cursor/Bitwarden once for icon/tray changes."
echo "Wallpaper: obtain Shinonome Ena card art *An Overwhelming Welcome!* yourself"
echo "  (see cozy-ena/README.md) — place under ~/Pictures/Wallpapers/ for splash"
echo "Login wallpaper (needs sudo): optional; see cozy-ena README."
