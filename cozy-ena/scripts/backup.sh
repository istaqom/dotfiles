#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STAMP=$(date +%Y%m%d-%H%M%S)
OUT="${BACKUP_DIR:-$ROOT/backups}/$STAMP"
mkdir -p "$OUT"
cp -a "$HOME/.config/kdeglobals" "$OUT/" 2>/dev/null || true
cp -a "$HOME/.config/plasmarc" "$OUT/" 2>/dev/null || true
cp -a "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$OUT/" 2>/dev/null || true
cp -a "$HOME/.config/kscreenlockerrc" "$OUT/" 2>/dev/null || true
echo "Backup -> $OUT"
echo "$OUT" > "$ROOT/.last-backup"
