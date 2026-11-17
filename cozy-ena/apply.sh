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
"$ROOT/scripts/apply-notify.sh"
"$ROOT/scripts/apply-kwin-notify-lower.sh"
"$ROOT/scripts/apply-bitwarden-tray.sh"

echo
echo "Done. If panels look stale: systemctl --user restart plasma-plasmashell.service"
echo "Restart Discord/Cursor/Bitwarden once for icon/tray changes."
echo "Wallpaper: download from https://www.zerochan.net/4637608"
echo "  save as ~/Pictures/Wallpapers/Shinonome.Ena.Petals-in-The-Wind.greenhouse.full.png"
echo "Login wallpaper (needs sudo): optional; see cozy-ena README."
