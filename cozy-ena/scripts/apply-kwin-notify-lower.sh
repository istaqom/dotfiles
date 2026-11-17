#!/usr/bin/env bash
# Install/enable KWin script: lower notification toasts to dock baseline
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ID="cozyena-notify-lower"
SRC="$ROOT/kwin-scripts/$ID"
DST="${HOME}/.local/share/kwin/scripts/$ID"
mkdir -p "$DST/contents/code"
cp -a "$SRC/metadata.json" "$DST/"
cp -a "$SRC/contents/code/main.js" "$DST/contents/code/"
kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" true
qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$ID" 2>/dev/null || true
qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript \
  "$DST/contents/code/main.js" "$ID" >/dev/null
qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start
echo "KWin: $ID loaded (toast bottom margin 10px)"
