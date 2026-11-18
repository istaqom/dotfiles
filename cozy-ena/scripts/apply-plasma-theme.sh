#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/.local/share/plasma/desktoptheme" "$HOME/.local/share/plasma/plasmoids" \
         "$HOME/.local/share/color-schemes"
rsync -a "$ROOT/plasma-theme/CozyEna/" "$HOME/.local/share/plasma/desktoptheme/CozyEna/"
# Plain cp — rsync can fail on odd plasmoid link trees ("Too many levels of symbolic links")
for applet in org.cozyena.bigclock org.cozyena.panelclock org.cozyena.mediadock; do
  rm -rf "$HOME/.local/share/plasma/plasmoids/$applet"
  cp -a "$ROOT/plasmoids/$applet" "$HOME/.local/share/plasma/plasmoids/$applet"
done
[[ -f "$ROOT/color-schemes/CozyEna.colors" ]] && cp -f "$ROOT/color-schemes/CozyEna.colors" "$HOME/.local/share/color-schemes/"

# Colors: Vapor in apps; CozyEna plasma chrome
plasma-apply-colorscheme Vapor >/dev/null 2>&1 || true
plasma-apply-desktoptheme CozyEna >/dev/null 2>&1 || true
plasma-apply-cursortheme Usagi >/dev/null 2>&1 || true
kwriteconfig6 --file plasmarc --group Theme --key name CozyEna
echo "Plasma theme: CozyEna + Vapor + Usagi"
