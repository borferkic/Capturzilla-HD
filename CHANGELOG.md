# Changelog

## 2.1.0 — 2026-11-22

### English

- Much lower latency: the picture arrives about 1 s sooner. mpv gets only the picture and drops its buffers right after it starts, so it no longer lags on 60 fps sources.
- The audio is played through a PipeWire loopback; the bar's volume and mute still control it.
- No more crashes when switching sources, recording or losing the signal: a separate ffmpeg reads the device instead of mpv.
- Finds the audio of each source by its USB port, so devices whose audio has a different name (e.g. Razer Ripsaw HD) get sound.
- Stopping a recording no longer freezes the app, and several windows can be open at once.
- Requires PipeWire's `pw-loopback`.

### Español

- Mucha menos latencia: la imagen llega cerca de 1 s antes. mpv recibe solo la imagen y vacía sus búferes apenas empieza, así que ya no se atrasa con fuentes de 60 fps.
- El audio se reproduce con un loopback de PipeWire; el volumen y el silencio de la barra lo siguen controlando.
- Ya no se cierra al cambiar de fuente, grabar o perder la señal: un ffmpeg aparte lee el dispositivo en vez de mpv.
- Busca el audio de cada fuente por su puerto USB, así que los dispositivos cuyo audio tiene otro nombre (p. ej. Razer Ripsaw HD) tienen sonido.
- Detener una grabación ya no congela la app, y se pueden abrir varias ventanas a la vez.
- Requiere `pw-loopback` de PipeWire.

## 2.0.0 — 2026-11-22

### English

- New icon: the camera lens is a cyan Godzilla eye and the spines are magenta.
- Redesigned gear menu: flat dark list with cyan icons, the current value on the right and the selected option marked in magenta.
- Pause button (`Space` / `p`) to freeze the picture, with a `PAUSED` badge. Resuming jumps back to the live picture.
- About and Quit buttons in the bar, next to the gear. Quit asks for confirmation (`Enter` confirms, `Esc` cancels) and warns that an ongoing recording will be saved.
- The bar keeps a fixed size whatever the window size, and the three center buttons are centered.
- Rounded volume slider with a round knob that stays inside the track.
- Long device names are shortened with "…".
- Clicking inside the window no longer moves it.

### Español

- Icono nuevo: el lente de la cámara es un ojo de Godzilla cyan y las púas son magenta.
- Menú del engrane rediseñado: lista oscura y recta con iconos cyan, el valor actual a la derecha y la opción elegida marcada en magenta.
- Botón de pausa (`Espacio` / `p`) para congelar la imagen, con un indicador `PAUSADO`. Al reanudar vuelve a la imagen en vivo.
- Botones de Acerca de y Salir en la barra, junto al engrane. Salir pide confirmación (`Enter` confirma, `Esc` cancela) y avisa que la grabación en curso se guardará.
- La barra mantiene un tamaño fijo sin importar el tamaño de la ventana, y los tres botones del centro quedan centrados.
- Barra de volumen redondeada con una perilla circular que no se sale del riel.
- Los nombres de dispositivo largos se acortan con "…".
- Hacer clic dentro de la ventana ya no la mueve.

## 1.0.0 — 2026-11-21

### English

- First release: live view of a capture card or webcam with low latency, without OBS.
- Bottom bar with volume, mute, screenshot and record buttons.
- Gear menu with Source, Quality and Language dropdowns, Search for sources again and About.
- Recording to MP4 (H.264 with NVIDIA NVENC + AAC) and PNG screenshots.
- Spanish, English, Russian and Ukrainian interface.

### Español

- Primera versión: vista en vivo de una capturadora o cámara web con baja latencia, sin OBS.
- Barra inferior con volumen, silencio y botones de captura y grabación.
- Menú del engrane con desplegables de Fuente, Calidad e Idioma, Buscar fuentes otra vez y Acerca de.
- Grabación en MP4 (H.264 con NVIDIA NVENC + AAC) y capturas en PNG.
- Interfaz en español, inglés, ruso y ucraniano.
