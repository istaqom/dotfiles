#!/usr/bin/env bash
# Swap stock mediacontroller for Cozy media dock (idle note / proportional when playing).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
QDBUS=$(command -v qdbus-qt6 || command -v qdbus6 || command -v qdbus)

rsync -a "$ROOT/plasmoids/org.cozyena.mediadock/" \
  "$HOME/.local/share/plasma/plasmoids/org.cozyena.mediadock/"

$QDBUS org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var panels = panels();
for (var i = 0; i < panels.length; i++) {
  var p = panels[i];
  if (p.location !== "bottom") continue;

  var ws = p.widgets();
  var hasCozy = false;
  for (var j = ws.length - 1; j >= 0; j--) {
    var t = "" + ws[j].type;
    if (t.indexOf("org.cozyena.mediadock") >= 0) {
      hasCozy = true;
      continue;
    }
    // drop stock media + gap spacer before it
    if (t.indexOf("mediacontroller") >= 0 || t.indexOf("marginsseparator") >= 0) {
      ws[j].remove();
    }
  }
  if (!hasCozy) {
    p.addWidget("org.cozyena.mediadock");
  }
  p.lengthMode = "fit";
  p.maximumLength = 480;
  p.minimumLength = 180;
  print("mediadock ok");
}
'
echo "Cozy media dock applied"
