#!/usr/bin/env bash
# Fix double Bitwarden tray (SNI + XEmbed) by preferring Wayland ozone
set -euo pipefail
if ! command -v flatpak >/dev/null; then
  echo "flatpak not found — skip"
  exit 0
fi
if flatpak info com.bitwarden.desktop >/dev/null 2>&1; then
  flatpak override --user --env=ELECTRON_OZONE_PLATFORM_HINT=wayland com.bitwarden.desktop
  echo "Bitwarden: ELECTRON_OZONE_PLATFORM_HINT=wayland (restart Bitwarden once)"
else
  echo "Bitwarden flatpak not installed — skip"
fi
