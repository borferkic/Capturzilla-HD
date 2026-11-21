<div align="center">
  <img width="96" height="96" alt="Capturzilla HD icon" src="icons/capturadora-256.png" />

  <h1>Capturzilla HD</h1>

  <a href="https://github.com/borferkic/Capturzilla-HD/releases/latest"><img src="https://img.shields.io/github/v/release/borferkic/Capturzilla-HD?style=flat-square&color=2ea44f" alt="Latest release" /></a>
  <img src="https://img.shields.io/badge/Platform-Omarchy%20%2F%20Arch%20Linux-1793D1?style=flat-square&logo=archlinux&logoColor=white" alt="Platform: Omarchy / Arch Linux" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License: MIT" /></a>
  <br />
  <a href="https://paypal.me/borissdk"><img src="https://img.shields.io/badge/Donate-PayPal-00457C?style=flat-square&logo=paypal&logoColor=white" alt="Donate with PayPal" /></a>
  <a href="https://patreon.com/borissdk"><img src="https://img.shields.io/badge/Support-Patreon-F96854?style=flat-square&logo=patreon&logoColor=white" alt="Support on Patreon" /></a>

  <p><a href="#english">English</a> | <a href="#espanol">Español</a></p>
</div>

<a id="english"></a>

**A minimal, low-latency viewer for your capture card or webcam on Omarchy: watch it live, control the volume, take screenshots and record, without OBS.**

Latest release: `1.0.0`.

<div align="center">
  <img alt="Gear menu with the Quality dropdown" src="docs/images/menu-quality.png" width="640" />
</div>

---

## Features

- **Live view**
  - Shows a capture card (such as the Elgato Cam Link) or a webcam at its best mode, for example 1080p 60 fps uncompressed, with low latency through mpv.
  - Plays the audio of the same device automatically.
  - If a source has no signal, a notice appears and the window stays open.
- **Bottom bar**
  - Volume slider, mute button and percentage. It appears when you move the mouse and hides after 2.5 s.
  - Screenshot and record buttons in the center, with the recording time.
  - Status with the current source and quality.
- **Gear menu**
  - **Source**: every video device connected, each one with its best mode. The Cam Link always comes first.
  - **Quality**: the original mode (for example `1080p · 60 fps (Original)`), 1080p 30 fps, 720p 60 fps and 720p 30 fps. It only changes the preview, never the recording.
  - **Language**: Español, English, Русский and Українська, with flags. The choice is remembered.
  - **Search for sources again** and **About**.
- **Screenshots and recording**
  - Screenshots are saved as PNG in `~/Pictures/Capturzilla`.
  - Recordings are saved as MP4 (H.264 + AAC) in `~/Videos/Capturzilla`, always at the original quality, encoded by the GPU (NVIDIA NVENC). A `● REC` indicator with the time is shown while recording.
  - If you close the window while recording, the video is kept.
- **Omarchy style**
  - Closes with `Super+W` like any Omarchy window (not with `q`). Fullscreen is handled by Omarchy.

## Screenshots

| Language dropdown | About |
|---|---|
| ![Gear menu with the Language dropdown and flags](docs/images/menu-language.png) | ![About window](docs/images/about.png) |

## Quick start

1. Open the [latest release](https://github.com/borferkic/Capturzilla-HD/releases/latest) and download the source code, or clone the repository.
2. Run `./install.sh`.
3. Open **Capturzilla HD** from the app launcher (`Super+Space`).

## Requirements

- Omarchy or Arch Linux (Hyprland / Wayland), with a Nerd Font (Omarchy ships JetBrainsMono Nerd Font).
- `mpv`, `ffmpeg`, `v4l-utils` and `libpulse` (`pactl`): `sudo pacman -S mpv ffmpeg v4l-utils libpulse`.
- A UVC capture card or webcam (it works without drivers on Linux).
- Recording needs an NVIDIA GPU with NVENC.

## Usage

| Input | Action |
| --- | --- |
| Mouse wheel / `9` / `0` | Volume |
| `m` | Mute |
| `s` | Screenshot |
| `r` | Start / stop recording |
| `Esc` | Close the menu or the About window |
| `Super+W` | Close the app |

## How it works

```text
Capture card / webcam (UVC, /dev/videoN) + its audio (PulseAudio / PipeWire)
                     │
        ┌────────────┴─────────────┐
   Watching                    Recording
        │                          │
  mpv reads the device     ffmpeg reads the device:
  directly (low-latency)   ├─ MP4 file (h264_nvenc + AAC)
        │                  └─ raw video through a FIFO ──► mpv
        ▼
  capturadora.lua: bar, gear menu, languages and About (libass overlay)
```

A capture card accepts only one reader at a time, so while recording ffmpeg owns the device and sends the picture to mpv through a FIFO. The preview pauses for about half a second when recording starts and stops.

## Uninstall

Run `./uninstall.sh`. Your screenshots and recordings are kept.

## License

Capturzilla HD is distributed under the MIT License. See [LICENSE](LICENSE). Release notes are in [CHANGELOG.md](CHANGELOG.md).

## Support the project

If you like Capturzilla HD and find it useful, you can support its development through **[PayPal](https://paypal.me/borissdk)** or **[Patreon](https://patreon.com/borissdk)**. Thank you for helping keep the project moving forward.

<a href="https://paypal.me/borissdk"><img src="https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white" alt="Donate with PayPal" /></a>
<a href="https://patreon.com/borissdk"><img src="https://img.shields.io/badge/Support-Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Support on Patreon" /></a>

---

<a id="espanol"></a>

## Español

**Un visor mínimo y de baja latencia para tu capturadora o cámara web en Omarchy: mírala en vivo, controla el volumen, saca capturas y graba, sin OBS.**

Última versión: `1.0.0`.

### Funcionalidades

- **Vista en vivo**
  - Muestra una capturadora (como la Elgato Cam Link) o una cámara web en su mejor modo, por ejemplo 1080p a 60 fps sin comprimir, con baja latencia gracias a mpv.
  - Reproduce automáticamente el audio del mismo dispositivo.
  - Si una fuente no tiene señal, aparece un aviso y la ventana sigue abierta.
- **Barra inferior**
  - Barra de volumen, botón de silencio y porcentaje. Aparece al mover el mouse y se oculta a los 2,5 s.
  - Botones de captura y grabación al centro, con el tiempo de grabación.
  - Estado con la fuente y la calidad actuales.
- **Menú del engrane**
  - **Fuente**: todos los dispositivos de video conectados, cada uno con su mejor modo. La Cam Link siempre sale primero.
  - **Calidad**: el modo original (por ejemplo `1080p · 60 fps (Original)`), 1080p 30 fps, 720p 60 fps y 720p 30 fps. Solo cambia la vista, nunca la grabación.
  - **Idioma**: Español, English, Русский y Українська, con banderas. La elección se recuerda.
  - **Buscar fuentes otra vez** y **Acerca de**.
- **Capturas y grabación**
  - Las capturas se guardan en PNG en `~/Pictures/Capturzilla`.
  - Las grabaciones se guardan en MP4 (H.264 + AAC) en `~/Videos/Capturzilla`, siempre en la calidad original y codificadas por la tarjeta gráfica (NVIDIA NVENC). Mientras graba se ve un indicador `● REC` con el tiempo.
  - Si cierras la ventana mientras grabas, el video se conserva.
- **Estilo Omarchy**
  - Se cierra con `Super+W` como cualquier ventana de Omarchy (no con `q`). La pantalla completa la maneja Omarchy.

### Capturas

| Desplegable de idioma | Acerca de |
|---|---|
| ![Menú del engrane con el desplegable de idioma y las banderas](docs/images/menu-language.png) | ![Ventana Acerca de](docs/images/about.png) |

### Inicio rápido

1. Abre la [última versión](https://github.com/borferkic/Capturzilla-HD/releases/latest) y descarga el código fuente, o clona el repositorio.
2. Ejecuta `./install.sh`.
3. Abre **Capturzilla HD** desde el lanzador de apps (`Super+Espacio`).

### Requisitos

- Omarchy o Arch Linux (Hyprland / Wayland), con una Nerd Font (Omarchy trae JetBrainsMono Nerd Font).
- `mpv`, `ffmpeg`, `v4l-utils` y `libpulse` (`pactl`): `sudo pacman -S mpv ffmpeg v4l-utils libpulse`.
- Una capturadora o cámara web UVC (funciona sin drivers en Linux).
- Para grabar hace falta una tarjeta NVIDIA con NVENC.

### Uso

| Entrada | Acción |
| --- | --- |
| Rueda del mouse / `9` / `0` | Volumen |
| `m` | Silenciar |
| `s` | Captura de pantalla |
| `r` | Empezar / detener la grabación |
| `Esc` | Cerrar el menú o el Acerca de |
| `Super+W` | Cerrar la app |

### Cómo funciona

Una capturadora solo admite un lector a la vez. Para ver la imagen, mpv lee el dispositivo directamente con baja latencia. Al grabar, ffmpeg toma el dispositivo, guarda el MP4 (h264_nvenc + AAC) y le pasa la imagen a mpv por un FIFO. Por eso la vista se pausa medio segundo al empezar y al terminar de grabar. La barra, el menú, los idiomas y el Acerca de están en `capturadora.lua`, dibujados con libass.

### Desinstalar

Ejecuta `./uninstall.sh`. Tus capturas y grabaciones se conservan.

### Licencia

Capturzilla HD se distribuye bajo la Licencia MIT. Consulta [LICENSE](LICENSE). Las notas de cada versión están en [CHANGELOG.md](CHANGELOG.md).

### Apoya el proyecto

Si te gusta Capturzilla HD y te resulta útil, puedes apoyar su desarrollo mediante **[PayPal](https://paypal.me/borissdk)** o **[Patreon](https://patreon.com/borissdk)**. Gracias por ayudar a que el proyecto siga avanzando.

<a href="https://paypal.me/borissdk"><img src="https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white" alt="Donar con PayPal" /></a>
<a href="https://patreon.com/borissdk"><img src="https://img.shields.io/badge/Support-Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Apoyar en Patreon" /></a>
