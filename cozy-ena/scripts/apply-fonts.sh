#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/.local/share/fonts/Comfortaa"
cp -a "$ROOT/fonts/Comfortaa/"*.ttf "$HOME/.local/share/fonts/Comfortaa/" 2>/dev/null || true
fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || fc-cache -f
FONT='Comfortaa,10,-1,5,50,0,0,0,0,0'
FONT_SM='Comfortaa,8,-1,5,50,0,0,0,0,0'
FONT_TB='Comfortaa,9,-1,5,50,0,0,0,0,0'
FONT_WM='Comfortaa,10,-1,5,57,0,0,0,0,0'
kwriteconfig6 --file kdeglobals --group General --key font "$FONT"
kwriteconfig6 --file kdeglobals --group General --key menuFont "$FONT"
kwriteconfig6 --file kdeglobals --group General --key toolBarFont "$FONT_TB"
kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "$FONT_SM"
kwriteconfig6 --file kdeglobals --group General --key desktopFont "$FONT"
kwriteconfig6 --file kdeglobals --group WM --key activeFont "$FONT_WM"
echo "Fonts: Comfortaa"
