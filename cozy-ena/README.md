# Cozy Ena (Plasma rice)

Clear top panel (wallpaper through) + opaque brown dock/popups + Vapor apps + Tela-circle-dark + Usagi cursor + Comfortaa + floating gold clock (cream date).

## Screenshots

![Desktop](../images/cozy-ena/desktop.jpg)

![Lock screen](../images/cozy-ena/lock.jpg)

![Login (lock screen password UI)](../images/cozy-ena/login.jpg)

![Launcher](../images/cozy-ena/launcher.jpg)

| Crop | Preview |
|------|---------|
| Clock | ![Clock](../images/cozy-ena/clock.png) |
| Top panel | ![Top panel](../images/cozy-ena/top-panel.png) |
| Dock | ![Dock](../images/cozy-ena/dock.png) |
| Login user | ![Login user](../images/cozy-ena/login-user.png) |

## Wallpaper (not bundled)

Download yourself — art is SEGA / Colorful Palette (Project SEKAI), not redistributed here.

| | |
|--|--|
| **Source** | [Zerochan #4637608](https://www.zerochan.net/4637608) — Shinonome Ena, *Petals in The Wind* (greenhouse) |
| **Save as** | `~/Pictures/Wallpapers/Shinonome.Ena.Petals-in-The-Wind.greenhouse.full.png` |
| **Then** | System Settings → Wallpaper / Lock screen → pick that file |

Optional login crop (Plasma Login Manager, needs sudo once): see notes in older `themes/cozy-ena/apply-login-wallpaper.sh` if present on this machine.

## One-shot apply

```bash
./cozy-ena/apply.sh
```

Backs up `kdeglobals` / `plasmarc` / appletsrc first → `cozy-ena/backups/`.

## What it installs

| Piece | Destination |
|-------|-------------|
| Plasma style `CozyEna` | `~/.local/share/plasma/desktoptheme/CozyEna` |
| Big clock + panel clock + media dock plasmoids | `~/.local/share/plasma/plasmoids/org.cozyena.*` |
| Splash screen `Cozy Ena` (`apply-splash.sh` copies your wallpaper in locally) | `~/.local/share/plasma/look-and-feel/org.cozyena.desktop` |
| Lock screen QML (date above clock, octagon avatar) | `~/.local/share/plasma/shells/.../lockscreen/` |
| Comfortaa | `~/.local/share/fonts/Comfortaa` |
| Usagi cursors | `~/.local/share/icons/Usagi` |
| Notify lower KWin script | dodgewindows-friendly toast drop |
| Gold Dolphin icon | override inside Tela-circle-dark |

## Prerequisites (not bundled)

- **Tela circle icons** (`Tela-circle-dark`)
- **Vapor** color scheme (Bazzite usually has it)
- Wallpaper from Zerochan link above

## Tray notes

- Discord / Cursor tray use **embedded pixmaps** → theme cannot restyle. Keep them **visible** in tray (dock still shows Tela app icons).
- Bitwarden double icon = SNI + XEmbed. Script sets `ELECTRON_OZONE_PLATFORM_HINT=wayland`; **restart Bitwarden** once.
- Volume slider uses gold Selection highlight for contrast on brown panel.
- Dock media (`org.cozyena.mediadock`): cream ♪ note when idle; expands to art + title only while playing.

## Partial scripts

```bash
./scripts/apply-fonts.sh
./scripts/apply-icons.sh
./scripts/apply-plasma-theme.sh
./scripts/apply-panels.sh
./scripts/apply-mediadock.sh
./scripts/apply-splash.sh
./scripts/apply-lockscreen.sh
./scripts/apply-notify.sh
./scripts/apply-kwin-notify-lower.sh
./scripts/apply-bitwarden-tray.sh
```

## Safe plasmashell restart

```bash
systemctl --user restart plasma-plasmashell.service
```

Do **not** use bare `plasmashell --replace` (can leave panels dead).
