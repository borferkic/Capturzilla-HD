#!/bin/bash
# Removes Capturzilla HD / Desinstala Capturzilla HD. Your screenshots and recordings are kept.
rm -f "$HOME/.local/bin/capturadora" \
  "$HOME/.config/capturadora/capturadora.lua" \
  "$HOME/.config/capturadora/idioma" \
  "$HOME/.config/capturadora/iconos/about-icono.bgra" \
  "$HOME/.local/share/icons/hicolor/scalable/apps/capturadora.svg" \
  "$HOME/.local/share/icons/hicolor/48x48/apps/capturadora.png" \
  "$HOME/.local/share/icons/hicolor/128x128/apps/capturadora.png" \
  "$HOME/.local/share/icons/hicolor/256x256/apps/capturadora.png" \
  "$HOME/.local/share/applications/capturadora.desktop"
rmdir "$HOME/.config/capturadora/iconos" "$HOME/.config/capturadora" 2>/dev/null || true
echo "Capturzilla HD removed / desinstalado."
