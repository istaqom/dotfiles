#!/usr/bin/env bash
# Opaque floating panels.
# Top: main fill panel (tray on RIGHT) + separate fit panel (clock CENTER).
# Does NOT change tray hide/show lists.
set -euo pipefail
QDBUS=$(command -v qdbus-qt6 || command -v qdbus6 || command -v qdbus)
$QDBUS org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var panels = panels();
for (var i = 0; i < panels.length; i++) {
  var p = panels[i];
  try { p.opacityMode = "Opaque"; } catch (e) {}
  if (p.location === "bottom") {
    p.floating = true;
    p.height = 52;
    p.lengthMode = "fit";
    p.alignment = "center";
    p.maximumLength = 560;
    // dodgewindows: no permanent bottom strut → toasts sit level with dock
    p.hiding = "dodgewindows";
  }
  if (p.location === "top") {
    // Non-floating: no extra float pad — bar hugs pills (~2px gap)
    p.floating = false;
    p.height = 26;
    var ws = p.widgets();
    var hasTray = false, hasClock = false;
    for (var j = 0; j < ws.length; j++) {
      var t = "" + ws[j].type;
      if (t.indexOf("systemtray") >= 0) hasTray = true;
      if (t === "org.kde.plasma.digitalclock") hasClock = true;
    }
    if (hasClock && !hasTray) {
      p.lengthMode = "fit";
      p.alignment = "center";
      p.maximumLength = 280;
    } else if (hasTray) {
      p.lengthMode = "fill";
    }
  }
}
print("panels ok");
'
echo "Panels applied (tray lists untouched)"
