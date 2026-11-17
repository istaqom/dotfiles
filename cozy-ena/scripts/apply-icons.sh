#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Usagi cursor
mkdir -p "$HOME/.local/share/icons"
rsync -a "$ROOT/icons/Usagi/" "$HOME/.local/share/icons/Usagi/"

# Gold Dolphin (readable on brown panels) — requires Tela-circle-dark installed
TELA="$HOME/.local/share/icons/Tela-circle-dark/scalable/apps"
if [[ -d "$TELA" ]]; then
  cp -f "$ROOT/icons/overrides/org.kde.dolphin.svg" "$TELA/system-file-manager.svg"
  ln -sfn system-file-manager.svg "$TELA/org.kde.dolphin.svg"
  ln -sfn system-file-manager.svg "$TELA/file-manager.svg"
  echo "Dolphin gold override applied"
else
  echo "WARN: Tela-circle-dark missing — install Tela circle icons first"
fi

# Discord desktop Icon=discord (Tela)
mkdir -p "$HOME/.local/share/applications"
if [[ -f "$ROOT/applications/com.discordapp.Discord.desktop" ]]; then
  cp -f "$ROOT/applications/com.discordapp.Discord.desktop" "$HOME/.local/share/applications/"
fi

# Cursor: if a cursor*.desktop exists, force Icon=cursor
for f in "$HOME"/.local/share/applications/cursor*.desktop; do
  [[ -f "$f" ]] || continue
  sed -i 's|^Icon=.*|Icon=cursor|' "$f"
done

kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-circle-dark
rm -f "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
echo "Icons: Tela-circle-dark + Usagi + overrides"
