#!/usr/bin/env bash
# Top: translucent + no panel chrome (wallpaper). Bottom: opaque brown.
# Requires Panel.qml override (translucent FrameSvg hidden) + AdaptiveTransparency=true.
set -euo pipefail
QDBUS=$(command -v qdbus-qt6 || command -v qdbus6 || command -v qdbus)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VIEWS="$HOME/.local/share/plasma/shells/org.kde.plasma.desktop/contents/views"
mkdir -p "$VIEWS"
if [ -f "$ROOT/plasma-shell-override/views/Panel.qml" ]; then
  cp -a /usr/share/plasma/shells/org.kde.plasma.desktop/contents/views/. "$VIEWS/" 2>/dev/null || true
  cp -a "$ROOT/plasma-shell-override/views/Panel.qml" "$VIEWS/Panel.qml"
fi
$QDBUS org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var panels = panels();
for (var i = 0; i < panels.length; i++) {
  var p = panels[i];
  if (p.location === "bottom") {
    p.opacity = "opaque";
    p.floating = true;
    p.height = 52;
    p.lengthMode = "fit";
    p.alignment = "center";
    p.maximumLength = 560;
    p.hiding = "dodgewindows";
  }
  if (p.location === "top") {
    p.opacity = "translucent";
    p.floating = false;
    p.height = 26;
    var ws = p.widgets();
    var hasTray = false;
    for (var j = 0; j < ws.length; j++) {
      if (("" + ws[j].type).indexOf("systemtray") >= 0) hasTray = true;
    }
    if (hasTray) p.lengthMode = "fill";
  }
}
print("panels ok");
'
echo "Panels applied (top clear / bottom opaque)"
