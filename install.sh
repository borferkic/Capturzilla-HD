#!/bin/bash
# Installs Capturzilla HD for the current user / Instala Capturzilla HD para el usuario actual.
set -e
cd "$(dirname "$0")"

for cmd in mpv ffmpeg v4l2-ctl pactl pw-loopback; do
  command -v "$cmd" >/dev/null || echo "Missing / Falta: $cmd  (sudo pacman -S mpv ffmpeg v4l-utils libpulse pipewire)"
done

install -Dm755 bin/capturadora "$HOME/.local/bin/capturadora"
install -Dm644 capturadora.lua "$HOME/.config/capturadora/capturadora.lua"
install -Dm644 icons/about-icono.bgra "$HOME/.config/capturadora/iconos/about-icono.bgra"
install -Dm644 icons/capturadora.svg "$HOME/.local/share/icons/hicolor/scalable/apps/capturadora.svg"
for s in 48 128 256; do
  install -Dm644 "icons/capturadora-$s.png" "$HOME/.local/share/icons/hicolor/${s}x${s}/apps/capturadora.png"
done
mkdir -p "$HOME/.local/share/applications"
sed "s|^Exec=.*|Exec=$HOME/.local/bin/capturadora|" capturadora.desktop > "$HOME/.local/share/applications/capturadora.desktop"
gtk-update-icon-cache -q -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo "Capturzilla HD installed / instalado. Open it from the app launcher / Ábrelo desde el lanzador de apps."
