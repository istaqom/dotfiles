#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Full shell copy required (partial lockscreen-only crash Plasma before)
SHELL_DST="$HOME/.local/share/plasma/shells/org.kde.plasma.desktop"
SHELL_SRC="/usr/share/plasma/shells/org.kde.plasma.desktop"
if [[ ! -d "$SHELL_DST/contents" ]]; then
  mkdir -p "$HOME/.local/share/plasma/shells"
  cp -a "$SHELL_SRC" "$SHELL_DST"
fi
mkdir -p "$SHELL_DST/contents/lockscreen"
cp -f "$ROOT/lockscreen/"*.qml "$SHELL_DST/contents/lockscreen/"
mkdir -p "$SHELL_DST/contents/lockscreen/fonts" 2>/dev/null || true
[[ -d "$ROOT/lockscreen/fonts" ]] && cp -a "$ROOT/lockscreen/fonts/." "$SHELL_DST/contents/lockscreen/fonts/" 2>/dev/null || true
# Prefer logo octagon as user face (transparent corners)
if [[ -f "$HOME/Pictures/logo-istaqom.png" ]]; then
  cp -f "$HOME/Pictures/logo-istaqom.png" "$HOME/.face"
fi
echo "Lockscreen: cozy clock+date + octagon avatar (test with Meta+L)"
