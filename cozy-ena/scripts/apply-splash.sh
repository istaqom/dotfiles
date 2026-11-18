#!/usr/bin/env bash
# Install + select Cozy Ena splash.
# Copies wallpaper into splash images/ (ksplash cannot load ~/ paths reliably).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.local/share/plasma/look-and-feel/org.cozyena.desktop"
mkdir -p "$(dirname "$DEST")"
rsync -a "$ROOT/look-and-feel/org.cozyena.desktop/" "$DEST/"

WALL=""
for c in \
  "$HOME/Pictures/Wallpapers/Shinonome.Ena.Petals-in-The-Wind.greenhouse.full.png" \
  "$HOME/Pictures/Wallpapers/ena-login-shifted-right.png" \
  "$HOME/Pictures/Wallpapers/ena-lock-shifted.png"
do
  [[ -f "$c" ]] && WALL="$c" && break
done

if [[ -z "$WALL" ]]; then
  echo "No wallpaper found under ~/Pictures/Wallpapers — splash keeps brown fallback" >&2
else
  python3 - "$WALL" "$DEST/contents/splash/images/background.jpg" "$DEST/contents/previews/splash.png" <<'PY'
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

wall, bg_out, preview_out = map(Path, sys.argv[1:4])
bg_out.parent.mkdir(parents=True, exist_ok=True)
preview_out.parent.mkdir(parents=True, exist_ok=True)

src = Image.open(wall).convert("RGB")

def cover(im, tw, th):
    scale = max(tw / im.width, th / im.height)
    nw, nh = int(im.width * scale), int(im.height * scale)
    im = im.resize((nw, nh), Image.LANCZOS)
    left, top = (nw - tw) // 2, (nh - th) // 2
    return im.crop((left, top, left + tw, top + th))

# Splash bg — 1920x1080 jpeg (local install only, not in git)
cover(src, 1920, 1080).save(bg_out, quality=88, optimize=True)

# Settings preview
prev = cover(src, 640, 400)
base = Image.alpha_composite(prev.convert("RGBA"), Image.new("RGBA", (640, 400), (107, 68, 35, 70)))
d = ImageDraw.Draw(base)
try:
    font = ImageFont.truetype(str(Path.home() / ".local/share/fonts/Comfortaa/Comfortaa-Bold.ttf"), 28)
    font2 = ImageFont.truetype(str(Path.home() / ".local/share/fonts/Comfortaa/Comfortaa-Bold.ttf"), 14)
except Exception:
    font = font2 = ImageFont.load_default()
# bottom chrome preview
d.ellipse([300, 280, 340, 320], outline=(244, 193, 90), width=2)
d.text((320, 300), "♪", fill=(255, 248, 236), font=font2, anchor="mm")
d.text((320, 340), "Cozy Ena", fill=(255, 248, 236), font=font, anchor="mm")
d.text((320, 370), "welcome home", fill=(244, 193, 90), font=font2, anchor="mm")
base.convert("RGB").save(preview_out, optimize=True, quality=85)
print("wallpaper ->", bg_out, bg_out.stat().st_size)
PY
fi

# never ship background.jpg in the git package tree
rm -f "$ROOT/look-and-feel/org.cozyena.desktop/contents/splash/images/background.jpg"

kwriteconfig6 --file ksplashrc --group KSplash --key Theme org.cozyena.desktop
kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
echo "Splash: Cozy Ena"
echo "Test: System Settings → Colors & Themes → Splash Screen → Test"
