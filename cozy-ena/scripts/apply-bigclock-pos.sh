#!/usr/bin/env bash
# Park org.cozyena.bigclock so lockAlign nudge in main.qml lands 1:1 with lock.
#
# Lock idle seat: x=(W-560)/2, y=round(H*0.08)  (LockScreenUi.qml)
# Plasma snaps desktop applets to an ~16px grid, so we store a calibrated
# geometry @ 1920x1080 (688,40 → live 688,74) and let QML nudge
# (lockAlignNudgeX/Y) finish the pixel match.
set -euo pipefail
export PATH="/usr/bin:/bin:/usr/local/bin:${HOME}/.local/bin:${PATH:-}"

CFG="${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc"
CLOCK_W=560
CLOCK_H=208

if [[ ! -f "$CFG" ]]; then
  echo "No appletsrc — skip bigclock position" >&2
  exit 0
fi

read -r SCREEN_W SCREEN_H < <(
  python3 - <<'PY'
import re, subprocess, sys
try:
    out = subprocess.check_output(["kscreen-doctor", "-o"], text=True, stderr=subprocess.DEVNULL)
except Exception:
    print("1920 1080")
    sys.exit(0)
blocks = re.split(r"\n(?=Output:)", out)
prim = blocks[0] if blocks else out
for b in blocks:
    if re.search(r"priority\s*1", b, re.I):
        prim = b
        break
m = re.search(r"Geometry:\s*[0-9]+,[0-9]+\s+([0-9]+)x([0-9]+)", prim)
print(f"{m.group(1)} {m.group(2)}" if m else "1920 1080")
PY
)

APPLET_ID=$(python3 - <<'PY'
from pathlib import Path
import re
t = Path.home().joinpath(".config/plasma-org.kde.plasma.desktop-appletsrc").read_text()
cur = None
for line in t.splitlines():
    m = re.match(r"\[Containments\]\[\d+\]\[Applets\]\[(\d+)\]", line)
    if m:
        cur = m.group(1)
        continue
    if cur and line.strip() == "plugin=org.cozyena.bigclock":
        print(cur)
        break
PY
)

if [[ -z "${APPLET_ID}" ]]; then
  echo "org.cozyena.bigclock not in appletsrc — skip position" >&2
  exit 0
fi

# Calibrated for 1920x1080 + QML lockAlign nudge. Scale from that baseline.
# Baseline store: x=688 y=40 (live lands ~688,74; nudge finishes 1:1 with lock).
BASE_W=1920
BASE_H=1080
BASE_X=688
BASE_Y=40
TARGET_X=$(python3 -c "print(round(${BASE_X} * ${SCREEN_W} / ${BASE_W}))")
TARGET_Y=$(python3 -c "print(round(${BASE_Y} * ${SCREEN_H} / ${BASE_H}))")
GEO="Applet-${APPLET_ID}:${TARGET_X},${TARGET_Y},${CLOCK_W},${CLOCK_H},0;"
echo "Bigclock → store ${GEO} @ ${SCREEN_W}x${SCREEN_H} (QML nudge completes lock match)"

systemctl --user stop plasma-plasmashell.service
while pgrep -x plasmashell >/dev/null; do sleep 0.2; done

SCREEN_W="$SCREEN_W" SCREEN_H="$SCREEN_H" APPLET_ID="$APPLET_ID" GEO="$GEO" python3 - <<'PY'
from pathlib import Path
import os, re
p = Path.home() / ".config/plasma-org.kde.plasma.desktop-appletsrc"
t = p.read_text()
aid = os.environ["APPLET_ID"]
geo = os.environ["GEO"]
sw, sh = os.environ["SCREEN_W"], os.environ["SCREEN_H"]
key = f"ItemGeometries-{sw}x{sh}"
pat = rf"({re.escape(key)}=)Applet-{aid}:\d+,\d+,\d+,\d+,\d+;"
t2, n = re.subn(pat, rf"\g<1>{geo}", t, count=1)
if n == 0 and f"{key}=" not in t2:
    t2 = t2.replace("[Containments][1]\n", f"[Containments][1]\n{key}={geo}\n", 1)
    n = 1
pat_h = rf"(ItemGeometriesHorizontal=)Applet-{aid}:\d+,\d+,\d+,\d+,\d+;"
t2, n2 = re.subn(pat_h, rf"\g<1>{geo}", t2, count=1)
p.write_text(t2)
print(f"patched res={n} horiz={n2}")
PY

# Prefer plain copy — rsync can choke on odd plasmoid link trees
SRC="$(cd "$(dirname "$0")/.." && pwd)/plasmoids/org.cozyena.bigclock"
DST="${HOME}/.local/share/plasma/plasmoids/org.cozyena.bigclock"
rm -rf "$DST"
cp -a "$SRC" "$DST"

systemctl --user start plasma-plasmashell.service
echo "Bigclock position + plasmoid applied"
