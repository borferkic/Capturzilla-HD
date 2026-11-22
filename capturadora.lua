-- Capturzilla HD: barra inferior de volumen y engrane con menú de fuente y calidad para mpv.
local utils = require "mp.utils"

local ICON_FONT = "JetBrainsMono Nerd Font"
local ICON_VOL, ICON_MUTE, ICON_GEAR = "\u{f028}", "\u{f026}", "\u{f013}"
local ICON_CAM, ICON_REC, ICON_STOP = "\u{f030}", "\u{f111}", "\u{f04d}"
local ICON_INFO, ICON_EXIT = "\u{f05a}", "\u{f011}"
local ICON_PAUSE, ICON_PLAY = "\u{f04c}", "\u{f04b}"

local PRESETS = {
  { name = "Original", vf = "" },
  { name = "1080p · 30 fps", vf = "scale=-2:1080,fps=30" },
  { name = "720p · 60 fps", vf = "scale=-2:720" },
  { name = "720p · 30 fps", vf = "scale=-2:720,fps=30" },
}

-- Idiomas: español, inglés, ruso y ucraniano. La elección se guarda en ~/.config/capturadora/idioma.
local LANGS = { "es", "en", "ru", "uk" }
local LANG_NAMES = { es = "Español", en = "English", ru = "Русский", uk = "Українська" }
local T = {
  es = { source = "Fuente", loading = "Cargando imagen…", searching = "Buscando fuentes…",
    no_devices = "No encuentro ninguna capturadora o cámara conectada",
    no_signal = "Sin señal en %s. Revisa el HDMI o elige otra fuente en el engrane.",
    quality = "Calidad", no_source = "Sin fuente", capture_source = "Fuente de captura",
    none_connected = "No hay fuentes conectadas", rescan = "Buscar fuentes otra vez", about = "Acerca de",
    language = "Idioma", original = "Original", version = "Versión",
    desc = "Mira tu capturadora o cámara en vivo, sin OBS,\\Ncon control de volumen y calidad a un clic.",
    support = "Puedes apoyar mi trabajo mediante PayPal o Patreon.", close = "Cerrar",
    shot_saved = "Captura guardada: %s", rec_saved = "Grabación guardada: %s",
    rec_failed = "No se pudo grabar. Revisa la fuente e inténtalo otra vez.", stop_first = "Detén la grabación primero",
    rec_starting = "Iniciando grabación…",
    paused = "PAUSADO", no_pause_rec = "No se puede congelar la imagen mientras grabas",
    quit_q = "¿Salir de Capturzilla HD?", quit_rec = "La grabación en curso se guardará.", quit_yes = "Salir", cancel = "Cancelar" },
  en = { source = "Source", loading = "Loading video…", searching = "Looking for sources…",
    no_devices = "No capture card or camera found",
    no_signal = "No signal on %s. Check the HDMI cable or pick another source from the gear menu.",
    quality = "Quality", no_source = "No source", capture_source = "Capture source",
    none_connected = "No sources connected", rescan = "Search for sources again", about = "About",
    language = "Language", original = "Original", version = "Version",
    desc = "Watch your capture card or camera live, without OBS,\\Nwith volume and quality one click away.",
    support = "You can support my work through PayPal or Patreon.", close = "Close",
    shot_saved = "Screenshot saved: %s", rec_saved = "Recording saved: %s",
    rec_failed = "Could not record. Check the source and try again.", stop_first = "Stop the recording first",
    rec_starting = "Starting recording…",
    paused = "PAUSED", no_pause_rec = "The picture cannot be frozen while recording",
    quit_q = "Quit Capturzilla HD?", quit_rec = "The current recording will be saved.", quit_yes = "Quit", cancel = "Cancel" },
  ru = { source = "Источник", loading = "Загрузка изображения…", searching = "Поиск источников…",
    no_devices = "Не найдено ни карты захвата, ни камеры",
    no_signal = "Нет сигнала на %s. Проверьте HDMI или выберите другой источник в меню шестерёнки.",
    quality = "Качество", no_source = "Нет источника", capture_source = "Источник захвата",
    none_connected = "Нет подключённых источников", rescan = "Повторить поиск источников", about = "О программе",
    language = "Язык", original = "Оригинал", version = "Версия",
    desc = "Смотрите карту захвата или камеру вживую без OBS,\\Nс регулировкой громкости и качества в один клик.",
    support = "Вы можете поддержать мою работу через PayPal или Patreon.", close = "Закрыть",
    shot_saved = "Снимок сохранён: %s", rec_saved = "Запись сохранена: %s",
    rec_failed = "Не удалось записать. Проверьте источник и попробуйте снова.", stop_first = "Сначала остановите запись",
    rec_starting = "Начинаем запись…",
    paused = "ПАУЗА", no_pause_rec = "Нельзя заморозить изображение во время записи",
    quit_q = "Выйти из Capturzilla HD?", quit_rec = "Текущая запись будет сохранена.", quit_yes = "Выйти", cancel = "Отмена" },
  uk = { source = "Джерело", loading = "Завантаження зображення…", searching = "Пошук джерел…",
    no_devices = "Не знайдено ні карти захоплення, ні камери",
    no_signal = "Немає сигналу на %s. Перевірте HDMI або виберіть інше джерело в меню шестерні.",
    quality = "Якість", no_source = "Немає джерела", capture_source = "Джерело захоплення",
    none_connected = "Немає підключених джерел", rescan = "Шукати джерела знову", about = "Про програму",
    language = "Мова", original = "Оригінал", version = "Версія",
    desc = "Дивіться карту захоплення або камеру наживо без OBS,\\Nз керуванням гучністю та якістю в один клік.",
    support = "Ви можете підтримати мою роботу через PayPal або Patreon.", close = "Закрити",
    shot_saved = "Знімок збережено: %s", rec_saved = "Запис збережено: %s",
    rec_failed = "Не вдалося записати. Перевірте джерело та спробуйте ще раз.", stop_first = "Спочатку зупиніть запис",
    rec_starting = "Починаємо запис…",
    paused = "ПАУЗА", no_pause_rec = "Не можна заморозити зображення під час запису",
    quit_q = "Вийти з Capturzilla HD?", quit_rec = "Поточний запис буде збережено.", quit_yes = "Вийти", cancel = "Скасувати" },
}
local LANG_FILE = mp.command_native({ "expand-path", "~/.config/capturadora/idioma" })
local lang = "es"
do
  local f = io.open(LANG_FILE, "r")
  local saved = f and f:read("*l"); if f then f:close() end
  local sys_lang = (os.getenv("LANG") or ""):sub(1, 2)
  lang = (saved and T[saved]) and saved or (T[sys_lang] and sys_lang) or "es"
end
local function L(key) return T[lang][key] or T.es[key] end
local function set_lang(l)
  lang = l
  local f = io.open(LANG_FILE, "w"); if f then f:write(l, "\n"); f:close() end
end

local ov = mp.create_osd_overlay("ass-events")
local current, visible, menu_open, dragging = 1, true, false, false
local sources, src_current = {}, 0
local rec = nil -- grabación en curso: { file, t0, started, stopping }
local paused = false -- imagen congelada con el botón de pausa
local pause_ov = mp.create_osd_overlay("ass-events")

-- "Original" muestra la resolución real de la fuente, p. ej. "1080p · 60 fps (Original)".
local function preset_name(i)
  if i ~= 1 then return PRESETS[i].name end
  local src = sources[src_current]
  if not src then return L("original") end
  return string.format("%dp · %d fps (%s)", src.mode.h, src.mode.fps, L("original"))
end
local hide_timer
local W, H = 1920, 1080
local zones = {}

local function run(args)
  local r = mp.command_native({ name = "subprocess", args = args, capture_stdout = true, playback_only = false })
  return (r and r.stdout) or ""
end

-- Busca dispositivos de captura y elige para cada uno el mejor modo (prioriza 1080p, luego fps).
local function scan_sources()
  local list, name, bus = {}, nil, nil
  for line in run({ "v4l2-ctl", "--list-devices" }):gmatch("[^\n]+") do
    if not line:match("^%s") then
      name = line:gsub("%s*%(.*$", ""):gsub(":.*$", "")
      bus = line:match("%(usb%-([%x:%.]+%-[%d%.]+)%)") -- p. ej. 0000:80:14.0-4
    elseif name and line:match("/dev/video%d+") then
      local dev = line:match("(/dev/video%d+)")
      local best, fmt, w, h = nil, nil, nil, nil
      for l in run({ "v4l2-ctl", "-d", dev, "--list-formats-ext" }):gmatch("[^\n]+") do
        local f = l:match("'(%w+)'")
        if f then fmt = f end
        local sw, sh = l:match("Size: Discrete (%d+)x(%d+)")
        if sw then w, h = tonumber(sw), tonumber(sh) end
        local fps = tonumber(l:match("%(([%d%.]+) fps%)") or "")
        if fps and w and (fmt == "YUYV" or fmt == "MJPG") then
          local score = math.min(h, 1080) * 1000 + fps * 10 + (fmt == "YUYV" and 1 or 0)
          if not best or score > best.score then
            best = { score = score, fmt = fmt, w = w, h = h, fps = math.floor(fps + 0.5) }
          end
        end
      end
      if best then
        list[#list + 1] = { name = name, dev = dev, mode = best, bus = bus }
      end
      name = nil -- solo el primer /dev/video de cada dispositivo captura imagen
    end
  end
  -- Audio del mismo dispositivo, si existe. Primero por el puerto USB (el nombre del audio
  -- no siempre coincide, p. ej. "Razer Ripsaw HD" -> Razer_Razer_Ripsaw_...), luego por nombre.
  local inputs, cur = {}, nil
  for l in run({ "pactl", "list", "sources" }):gmatch("[^\n]+") do
    local id = l:match("^%s*Name:%s*(%S+)")
    if id then
      cur = not id:match("%.monitor$") and { id = id } or nil
      if cur then inputs[#inputs + 1] = cur end
    end
    local bp = l:match('device%.bus_path%s*=%s*"([^"]+)"')
    if cur and bp then cur.bus_path = bp end
  end
  for _, s in ipairs(list) do
    if s.bus then
      local ctrl, port = s.bus:match("^(.-)%-([%d%.]+)$")
      local want = ctrl and ("pci-" .. ctrl .. "-usb-0:" .. port .. ":")
      for _, i in ipairs(inputs) do
        if want and i.bus_path and i.bus_path:sub(1, #want) == want then s.audio = i.id; break end
      end
    end
    if not s.audio then
      local key = s.name:gsub(" ", "_")
      for _, i in ipairs(inputs) do
        if i.id:find(key, 1, true) then s.audio = i.id; break end
      end
    end
  end
  -- Si no, por nombre de tarjeta ALSA igual al de vídeo (p. ej. "Razer Ripsaw HD").
  local by_card, cur = {}, nil
  for l in run({ "pactl", "list", "sources" }):gmatch("[^\n]+") do
    local n = l:match("^%s*Name:%s*(%S+)")
    if n then cur = not n:match("%.monitor$") and n or nil end
    local c = l:match('alsa%.card_name%s*=%s*"(.-)"')
    if c and cur and not by_card[c] then by_card[c] = cur end
  end
  for _, s in ipairs(list) do
    if not s.audio then s.audio = by_card[s.name] end
  end
  table.sort(list, function(a, b) -- la Cam Link primero
    local ca, cb = a.name:find("Cam Link") ~= nil, b.name:find("Cam Link") ~= nil
    if ca ~= cb then return ca end
    return a.dev < b.dev
  end)
  return list
end

-- Nombre corto para la barra y el menú: máximo 20 caracteres, cortando en una palabra y con "…".
local function short_name(name)
  local MAX = 20
  if #name:gsub("[\128-\191]", "") <= MAX then return name end
  local out = ""
  for w in name:gmatch("%S+") do
    local nxt = out == "" and w or (out .. " " .. w)
    if #nxt:gsub("[\128-\191]", "") > MAX then break end
    out = nxt
  end
  if out == "" then out = name:sub(1, MAX):gsub("[\192-\255][\128-\191]*$", "") end
  return out .. "…"
end

local function src_label(s)
  return string.format("%s · %dp %d fps", short_name(s.name), s.mode.h, s.mode.fps)
end

local PLACEHOLDER = "av://lavfi:color=c=0x101318:s=1280x720:r=30" -- igual que en ~/.local/bin/capturadora
local load_ov = mp.create_osd_overlay("ass-events")

-- Pantalla de carga: solo el mensaje centrado.
local function start_loading(msg)
  local d = mp.get_property_native("osd-dimensions") or {}
  local w, h = d.w or 1280, d.h or 720
  load_ov.res_x, load_ov.res_y = w, h
  load_ov.data = string.format("{\\an5\\pos(%d,%d)\\fs28\\bord2\\3c&H000000&\\1c&HFFFFFF&}%s", w / 2, h / 2, msg)
  load_ov:update()
end

local function stop_loading()
  load_ov:remove()
end

-- La cámara la lee un ffmpeg aparte y le pasa la imagen a mpv por un FIFO: el lector v4l2 de
-- ffmpeg dentro de mpv se cae (segfault) al cerrar la cámara con cuadros todavía en uso.
local VIEW_DIR = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/capturzilla-" .. utils.getpid() -- uno por ventana
local VIEW_PIDF, VIEW_LOGF = VIEW_DIR .. "/view.pid", VIEW_DIR .. "/view.log"
local view_n, view_fifo, view_entry = 0, nil, nil

local function stop_view()
  view_entry = nil
  local f = io.open(VIEW_PIDF, "r")
  local pid = f and f:read("*l"); if f then f:close() end
  if pid and pid ~= "" then
    run({ "sh", "-c", 'kill "$0" 2>/dev/null; for i in $(seq 30); do kill -0 "$0" 2>/dev/null || exit 0; sleep 0.1; done; kill -9 "$0"', pid })
  end
  os.remove(VIEW_PIDF)
  if view_fifo then
    -- Si mpv sigue esperando el FIFO (ffmpeg murió antes de abrirlo), abrirlo lo libera.
    local h = io.open(view_fifo, "r+"); if h then h:close() end
    os.remove(view_fifo); view_fifo = nil
  end
end

local function start_view(s)
  stop_view()
  view_n = view_n + 1
  view_fifo = VIEW_DIR .. "/view-" .. view_n .. ".nut"
  os.remove(view_fifo)
  run({ "mkdir", "-p", VIEW_DIR })
  run({ "mkfifo", view_fifo })
  -- Si ffmpeg termina (sin señal, cámara desconectada), se abre el FIFO para que mpv no se quede esperando.
  -- Solo imagen: el audio lo pasa PipeWire aparte (start_audio), si no mpv retrasa la imagen para sincronizarla.
  mp.command_native_async({ name = "subprocess", playback_only = false, detach = true, args = {
    "sh", "-c", 'p=$0 f=$1 l=$2; shift 2; "$@" 2>"$l" & echo $! > "$p"; wait $!; [ -p "$f" ] && : 3<>"$f"',
    VIEW_PIDF, view_fifo, VIEW_LOGF,
    "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
    "-f", "v4l2", "-input_format", s.mode.fmt == "YUYV" and "yuyv422" or "mjpeg",
    "-video_size", s.mode.w .. "x" .. s.mode.h, "-framerate", tostring(s.mode.fps), "-i", s.dev,
    "-map", "0:v", "-c:v", "copy", "-flush_packets", "1", "-f", "nut", view_fifo } }, function() end)
  return view_fifo
end

-- Audio de la fuente directo a los parlantes con un loopback de PipeWire (baja latencia).
-- La barra sigue usando el volumen y el silencio de mpv; se copian al loopback.
local AUDIO_PIDF, AUDIO_NODE = VIEW_DIR .. "/audio.pid", "capturzilla-audio-" .. utils.getpid()
local audio_idx -- índice del sink-input del loopback en PulseAudio

local function stop_audio()
  audio_idx = nil
  local f = io.open(AUDIO_PIDF, "r")
  local pid = f and f:read("*l"); if f then f:close() end
  if pid and pid ~= "" then run({ "kill", pid }) end
  os.remove(AUDIO_PIDF)
end

local function apply_volume()
  if not audio_idx then
    local cur
    for l in run({ "pactl", "list", "sink-inputs" }):gmatch("[^\n]+") do
      cur = l:match("^Sink Input #(%d+)") or cur
      if l:find('node.name = "' .. AUDIO_NODE .. '"', 1, true) then audio_idx = cur; break end
    end
    if not audio_idx then return end
  end
  local vol = math.floor(mp.get_property_number("volume", 100) + 0.5)
  run({ "pactl", "set-sink-input-volume", audio_idx, vol .. "%" })
  run({ "pactl", "set-sink-input-mute", audio_idx, mp.get_property_bool("mute", false) and "1" or "0" })
end

local function start_audio(s)
  stop_audio()
  if not s.audio then return end
  run({ "mkdir", "-p", VIEW_DIR })
  mp.command_native_async({ name = "subprocess", playback_only = false, detach = true, args = {
    "sh", "-c", 'echo $$ > "$0"; exec "$@" 2>/dev/null', AUDIO_PIDF,
    "pw-loopback", "-n", AUDIO_NODE, "-l", "20", "-C", s.audio,
    "--playback-props", "node.name=" .. AUDIO_NODE .. " media.name=Capturzilla application.name=Capturzilla" } }, function() end)
  mp.add_timeout(0.5, apply_volume) -- cuando PipeWire ya creó el nodo
end

local function open_source(i)
  local s = sources[i]
  if not s then return end
  if rec then mp.osd_message(L("stop_first"), 2); return end
  if paused then paused = false; pause_ov:remove(); mp.set_property_bool("pause", false) end
  src_current = i
  start_loading(L("loading"))
  mp.set_property_native("demuxer-lavf-o", {})
  mp.set_property_native("audio-files", {})
  local r = mp.command_native({ "loadfile", start_view(s), "replace" })
  view_entry = r and r.playlist_entry_id
  start_audio(s)
  mp.osd_message(L("source") .. ": " .. src_label(s), 2)
end

-- Capturas y grabación. La imagen original (sin el filtro de calidad) se graba con ffmpeg en la
-- RTX (h264_nvenc) y a la vez se le pasa a mpv por un FIFO, porque la capturadora solo admite un lector.
local function user_dir(kind, fallback)
  local d = run({ "xdg-user-dir", kind }):gsub("%s+$", "")
  if d == "" or d == os.getenv("HOME") then d = mp.command_native({ "expand-path", fallback }) end
  return d
end
local SHOT_DIR = user_dir("PICTURES", "~/Pictures") .. "/Capturzilla"
local REC_DIR = user_dir("VIDEOS", "~/Videos") .. "/Capturzilla"
local RUNTIME = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local FIFO, PIDF, LOGF = RUNTIME .. "/capturzilla-rec.nut", RUNTIME .. "/capturzilla-rec.pid", RUNTIME .. "/capturzilla-rec.log"
local rec_ov = mp.create_osd_overlay("ass-events")
local rec_timer, render -- render se define más abajo

-- Tamaño fijo de la interfaz (barra de 64 px), sin importar el tamaño de la ventana;
-- solo se ajusta a la escala del monitor (HiDPI).
local function ui_scale() return mp.get_property_number("display-hidpi-scale", 1) or 1 end

local function short_path(f) return (f:gsub("^" .. (os.getenv("HOME") or "~"):gsub("%p", "%%%0"), "~")) end
local function stamp() return os.date("Capturzilla_%Y-%m-%d_%H-%M-%S") end
local function live()
  local p = mp.get_property("path") or ""
  return (view_fifo ~= nil and p == view_fifo) or p == FIFO
end

local function take_screenshot()
  if not live() then mp.osd_message(L("no_source"), 2); return end
  run({ "mkdir", "-p", SHOT_DIR })
  local f = SHOT_DIR .. "/" .. stamp() .. ".png"
  mp.commandv("screenshot-to-file", f, "video")
  mp.osd_message(string.format(L("shot_saved"), short_path(f)), 3)
end

local function rec_pid()
  local f = io.open(PIDF, "r"); if not f then return nil end
  local pid = f:read("*l"); f:close(); return pid
end
local function alive(pid) local f = pid and io.open("/proc/" .. pid .. "/stat", "r"); if f then f:close(); return true end return false end
local function file_size(f) local h = io.open(f, "rb"); if not h then return 0 end local n = h:seek("end"); h:close(); return n end

local function draw_rec()
  if not rec then rec_ov:remove(); return end
  local d = mp.get_property_native("osd-dimensions") or {}
  local w, h = (d.w and d.w > 0) and d.w or 1280, (d.h and d.h > 0) and d.h or 720
  local t = math.floor(mp.get_time() - rec.t0)
  rec_ov.res_x, rec_ov.res_y = w, h
  rec_ov.data = string.format("{\\an7\\pos(%d,%d)\\fs%d\\bord2\\3c&H000000&\\1c&H3539E5&\\fn%s}%s{\\fn\\1c&HFFFFFF&} REC %02d:%02d",
    math.floor(30 * ui_scale()), math.floor(30 * ui_scale()), math.floor(30 * ui_scale()), ICON_FONT, ICON_REC, math.floor(t / 60), t % 60)
  rec_ov:update()
end

local function finish_rec()
  local was = rec
  rec = nil
  if rec_timer then rec_timer:kill(); rec_timer = nil end
  os.remove(FIFO); os.remove(PIDF)
  draw_rec()
  if file_size(was.file) > 100000 then
    mp.osd_message(string.format(L("rec_saved"), short_path(was.file)), 5)
  else
    os.remove(was.file)
    local lf = io.open(LOGF, "r"); if lf then mp.msg.error(lf:read("*a")); lf:close() end
    mp.osd_message(L("rec_failed"), 5)
  end
  open_source(src_current)
  render()
end

local function stop_rec()
  if not rec or not rec.started or rec.stopping then return end
  rec.stopping = true
  local pid = rec_pid()
  if pid then run({ "kill", "-INT", pid }) end
end

local function start_rec()
  local s = sources[src_current]
  if rec or not s or not live() then if not s then mp.osd_message(L("no_source"), 2) end return end
  run({ "mkdir", "-p", REC_DIR })
  os.remove(FIFO); os.remove(PIDF)
  run({ "mkfifo", FIFO })
  local file = REC_DIR .. "/" .. stamp() .. ".mp4"
  local a = { "sh", "-c", 'echo $$ > "$1"; shift; exec "$@" 2>"$0"', LOGF, PIDF,
    "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
    "-f", "v4l2", "-input_format", s.mode.fmt == "YUYV" and "yuyv422" or "mjpeg",
    "-video_size", s.mode.w .. "x" .. s.mode.h, "-framerate", tostring(s.mode.fps), "-i", s.dev }
  local function add(...) for _, v in ipairs({ ... }) do a[#a + 1] = v end end
  if s.audio then add("-f", "pulse", "-fragment_size", "1920", "-i", s.audio) end
  add("-map", "0:v")
  if s.audio then add("-map", "1:a", "-c:a", "aac", "-b:a", "192k") end
  add("-vf", "format=yuv420p", "-c:v", "h264_nvenc", "-preset", "p5", "-tune", "hq", "-rc", "vbr", "-cq", "19", "-b:v", "0",
    "-movflags", "+frag_keyframe+empty_moov+default_base_moof", file,
    "-map", "0:v", "-c:v", "rawvideo", "-flush_packets", "1", "-f", "nut", FIFO) -- el audio sigue por el loopback
  if paused then paused = false; pause_ov:remove(); mp.set_property_bool("pause", false) end
  rec = { file = file, t0 = mp.get_time() }
  start_loading(L("rec_starting"))
  -- mpv suelta la capturadora y espera la imagen por el FIFO; luego arranca ffmpeg.
  stop_view()
  mp.set_property_native("demuxer-lavf-o", {})
  mp.commandv("loadfile", FIFO, "replace")
  mp.add_timeout(0.5, function()
    mp.command_native_async({ name = "subprocess", args = a, playback_only = false, detach = true }, function() end)
    rec.started = true
    rec.t0 = mp.get_time()
    rec_timer = mp.add_periodic_timer(0.5, function()
      if not rec then return end
      local pid = rec_pid()
      if mp.get_time() - rec.t0 > 2 and not alive(pid) then
        -- ffmpeg terminó (detenido o con error): si mpv sigue esperando el FIFO, se libera abriéndolo.
        local f = io.open(FIFO, "r+"); if f then f:close() end -- r+ no se bloquea si mpv ya lo cerró
        finish_rec()
      else
        draw_rec()
        if visible then render() end
      end
    end)
    draw_rec()
    if render then render() end
  end)
end

local function toggle_rec() if rec then stop_rec() else start_rec() end end

local function col(rgb) -- "RRGGBB" -> ASS &HBBGGRR&
  return "&H" .. rgb:sub(5, 6) .. rgb:sub(3, 4) .. rgb:sub(1, 2) .. "&"
end

local function rect(x, y, w, h, color, alpha)
  return string.format("{\\an7\\pos(0,0)\\bord0\\shad0\\1c%s\\1a&H%s&\\p1}m %d %d l %d %d %d %d %d %d{\\p0}",
    col(color), alpha or "00", x, y, x + w, y, x + w, y + h, x, y + h)
end

-- Rectángulo con esquinas redondeadas (curvas Bézier de ASS); extra admite p. ej. "\\blur12".
local function rrect(x, y, w, h, r, color, alpha, extra)
  local k = math.floor(r * 0.45)
  return string.format("{\\an7\\pos(0,0)\\bord0\\shad0%s\\1c%s\\1a&H%s&\\p1}m %d %d l %d %d b %d %d %d %d %d %d l %d %d b %d %d %d %d %d %d l %d %d b %d %d %d %d %d %d l %d %d b %d %d %d %d %d %d{\\p0}",
    extra or "", col(color), alpha or "00",
    x + r, y, x + w - r, y, x + w - k, y, x + w, y + k, x + w, y + r,
    x + w, y + h - r, x + w, y + h - k, x + w - k, y + h, x + w - r, y + h,
    x + r, y + h, x + k, y + h, x, y + h - k, x, y + h - r,
    x, y + r, x, y + k, x + k, y, x + r, y)
end

local function text(x, y, an, size, color, s, font)
  return string.format("{\\an%d\\pos(%d,%d)\\fs%d\\bord0\\shad0\\1c%s%s}%s",
    an, x, y, size, col(color), font and ("\\fn" .. font) or "", s)
end

-- Ventana "Acerca de" (mismo contenido que el de BT Device Battery Info).
local VERSION = "2.1.0"
local SOCIAL = {
  { name = "Instagram", icon = "\u{f16d}", url = "https://www.instagram.com/borissdk/" },
  { name = "Twitch", icon = "\u{f1e8}", url = "https://www.twitch.tv/borizillaTV" },
  { name = "LinkedIn", icon = "\u{f0e1}", url = "https://www.linkedin.com/in/borissdk/" },
}
local SUPPORT = {
  { name = "PayPal", icon = "\u{f1ed}", url = "https://paypal.me/borissdk" },
  { name = "Patreon", icon = "\u{f3d9}", url = "https://patreon.com/borissdk" },
}
local about_open = false
local ABOUT_ICON = mp.command_native({ "expand-path", "~/.config/capturadora/iconos/about-icono.bgra" }) -- 120x120

local function open_url(url)
  mp.command_native_async({ name = "subprocess", args = { "xdg-open", url }, playback_only = false, detach = true }, function() end)
end

local function link_row(out, list, cx, y, s)
  local cw = math.floor(84 * s)
  local x0 = cx - cw * #list / 2
  for i, l in ipairs(list) do
    local x = x0 + cw * (i - 1)
    local bs = math.floor(32 * s)
    out[#out + 1] = rect(x + (cw - bs) / 2, y, bs, bs, "262B35", "00")
    out[#out + 1] = text(x + cw / 2, y + bs / 2, 5, math.floor(17 * s), "FFFFFF", l.icon, ICON_FONT)
    out[#out + 1] = text(x + cw / 2, y + bs + math.floor(14 * s), 5, math.floor(15 * s), "4FA3FF", l.name)
    zones.links[#zones.links + 1] = { x = x, y = y, w = cw, h = bs + math.floor(26 * s), url = l.url }
  end
end

local function draw_about(out, s)
  local cw, ch = math.floor(440 * s), math.floor(480 * s) + 120 -- el icono (120 px) no se escala
  local cx0, cy0 = math.floor((W - cw) / 2), math.floor((H - ch) / 2)
  local mid = cx0 + cw / 2
  zones.about = { x = cx0, y = cy0, w = cw, h = ch }
  zones.links = {}
  out[#out + 1] = rect(0, 0, W, H, "000000", "70")
  out[#out + 1] = rect(cx0, cy0, cw, ch, "15181E", "00")
  out[#out + 1] = text(cx0 + math.floor(24 * s), cy0 + math.floor(30 * s), 4, math.floor(18 * s), "9AA3B2", L("about"))
  local iy = cy0 + math.floor(56 * s)
  mp.commandv("overlay-add", "2", tostring(math.floor(mid - 60)), tostring(iy), ABOUT_ICON, "0", "bgra", "120", "120", "480")
  local y = iy + 120 + math.floor(18 * s)
  out[#out + 1] = text(mid, y, 5, math.floor(28 * s), "FFFFFF", "Capturzilla HD")
  out[#out + 1] = text(mid, y + math.floor(28 * s), 5, math.floor(15 * s), "9AA3B2", L("version") .. " " .. VERSION)
  out[#out + 1] = string.format("{\\an8\\pos(%d,%d)\\q0\\fs%d\\bord0\\shad0\\1c%s}%s", mid, y + math.floor(50 * s),
    math.floor(16 * s), col("9AA3B2"), L("desc"))
  link_row(out, SOCIAL, mid, y + math.floor(108 * s), s)
  out[#out + 1] = text(mid, y + math.floor(196 * s), 5, math.floor(16 * s), "9AA3B2", L("support"))
  link_row(out, SUPPORT, mid, y + math.floor(220 * s), s)
  local by = cy0 + ch - math.floor(56 * s)
  out[#out + 1] = text(mid, by - math.floor(18 * s), 5, math.floor(14 * s), "9AA3B2", "© 2026 Boris SdK")
  local bw, bh = math.floor(120 * s), math.floor(38 * s)
  out[#out + 1] = rect(mid - bw / 2, by, bw, bh, "4FA3FF", "00")
  out[#out + 1] = text(mid, by + bh / 2, 5, math.floor(18 * s), "15181E", L("close"))
  zones.about_close = { x = mid - bw / 2, y = by, w = bw, h = bh }
end

-- Confirmación antes de salir con el botón ⏻.
local quit_open = false
local function draw_quit(out, s)
  local cw, ch = math.floor(400 * s), math.floor((rec and 190 or 160) * s)
  local x0, y0 = math.floor((W - cw) / 2), math.floor((H - ch) / 2)
  local mid = x0 + cw / 2
  zones.quit = { x = x0, y = y0, w = cw, h = ch }
  out[#out + 1] = rect(0, 0, W, H, "000000", "70")
  out[#out + 1] = rect(x0, y0, cw, ch, "0D0F14", "00")
  out[#out + 1] = rect(x0, y0, cw, math.floor(4 * s), "E8179A", "00")
  out[#out + 1] = text(mid, y0 + math.floor(48 * s), 5, math.floor(21 * s), "FFFFFF", "{\\b1}" .. L("quit_q"))
  if rec then
    out[#out + 1] = text(mid, y0 + math.floor(82 * s), 5, math.floor(15 * s), "9AA3B2", L("quit_rec"))
  end
  local bw, bh, gap = math.floor(140 * s), math.floor(40 * s), math.floor(16 * s)
  local by = y0 + ch - bh - math.floor(24 * s)
  local cx, qx = mid - gap / 2 - bw, mid + gap / 2
  out[#out + 1] = rect(cx, by, bw, bh, "262B35", "00")
  out[#out + 1] = text(cx + bw / 2, by + bh / 2, 5, math.floor(17 * s), "FFFFFF", L("cancel"))
  out[#out + 1] = rect(qx, by, bw, bh, "E8179A", "00")
  out[#out + 1] = text(qx + bw / 2, by + bh / 2, 5, math.floor(17 * s), "FFFFFF", "{\\b1}" .. L("quit_yes"))
  zones.quit_no = { x = cx, y = by, w = bw, h = bh }
  zones.quit_yes = { x = qx, y = by, w = bw, h = bh }
end

local function close_about()
  about_open = false
  mp.commandv("overlay-remove", "2")
end

-- Banderas dibujadas con rectángulos (libass no muestra emojis a color).
local function draw_flag(out, code, x, y, w, h)
  local function band(fy, fh, color, fx, fw) out[#out + 1] = rect(math.floor(fx or x), math.floor(fy), math.floor(fw or w), math.max(1, math.floor(fh)), color, "00") end
  if code == "es" then
    band(y, h / 4, "AA151B"); band(y + h / 4, h / 2, "F1BF00"); band(y + h * 3 / 4, h - math.floor(h * 3 / 4), "AA151B")
  elseif code == "en" then
    band(y, h, "FFFFFF")
    for k = 0, 12, 2 do band(y + h * k / 13, h / 13 + 0.5, "B22234") end
    band(y, h * 7 / 13, "3C3B6E", x, w * 0.42)
  elseif code == "ru" then
    band(y, h / 3, "FFFFFF"); band(y + h / 3, h / 3, "0039A6"); band(y + h * 2 / 3, h - math.floor(h * 2 / 3), "D52B1E")
  elseif code == "uk" then
    band(y, h / 2, "0057B7"); band(y + h / 2, h - math.floor(h / 2), "FFD700")
  end
end

local open_dd = nil -- desplegable abierto en el menú: "src", "q" o "lang"

-- Insignia "⏸ PAUSADO" arriba a la izquierda mientras la imagen está congelada.
local function draw_pause()
  if not paused then pause_ov:remove(); return end
  local d = mp.get_property_native("osd-dimensions") or {}
  local w, h = (d.w and d.w > 0) and d.w or 1280, (d.h and d.h > 0) and d.h or 720
  local s = ui_scale()
  local x, y, bh = math.floor(30 * s), math.floor(30 * s), math.floor(50 * s)
  local label = L("paused")
  local bw = math.floor((92 + 18 * #label:gsub("[\128-\191]", "")) * s) -- ancho según letras (UTF-8)
  pause_ov.res_x, pause_ov.res_y = w, h
  pause_ov.data = table.concat({
    rrect(x, y, bw, bh, math.floor(bh / 2), "000000", "60"),
    text(x + math.floor(28 * s), y + bh / 2, 4, math.floor(21 * s), "22D3EE", ICON_PAUSE, ICON_FONT),
    text(x + math.floor(60 * s), y + bh / 2, 4, math.floor(21 * s), "FFFFFF", "{\\b1\\fsp3}" .. label),
  }, "\n")
  pause_ov:update()
end

-- Congela la imagen o vuelve a la imagen en vivo (sin el retraso acumulado mientras estuvo en pausa).
local function toggle_pause()
  if not paused then
    if rec then mp.osd_message(L("no_pause_rec"), 3); return end
    if not live() then return end
    paused = true
    mp.set_property_bool("pause", true)
  else
    paused = false
    mp.command("drop-buffers")
    mp.set_property_bool("pause", false)
  end
  draw_pause()
end

local function menu_rows()
  local rows = {}
  local function dd(which, title, value)
    rows[#rows + 1] = { kind = "dd", which = which, title = title, value = value }
  end
  local cur = sources[src_current]
  dd("src", L("source"), cur and src_label(cur) or L("no_source"))
  if open_dd == "src" then
    if #sources == 0 then rows[#rows + 1] = { kind = "info", label = L("none_connected") } end
    for i, src in ipairs(sources) do rows[#rows + 1] = { kind = "opt", which = "src", i = i, label = src_label(src), on = i == src_current } end
  end
  dd("q", L("quality"), preset_name(current))
  if open_dd == "q" then
    for i in ipairs(PRESETS) do rows[#rows + 1] = { kind = "opt", which = "q", i = i, label = preset_name(i), on = i == current } end
  end
  dd("lang", L("language"), LANG_NAMES[lang])
  if open_dd == "lang" then
    for i, l in ipairs(LANGS) do rows[#rows + 1] = { kind = "opt", which = "lang", i = i, flag = l, label = LANG_NAMES[l], on = l == lang } end
  end
  rows[#rows + 1] = { kind = "rescan", label = L("rescan") }
  return rows
end

render = function()
  local d = mp.get_property_native("osd-dimensions") or {}
  W, H = d.w or W, d.h or H
  ov.res_x, ov.res_y = W, H
  zones = {}
  if not visible and not menu_open and not about_open and not quit_open then ov.data = ""; ov:update(); return end

  local s = ui_scale()
  local bh = math.floor(64 * s)
  local by = H - bh
  local pad = math.floor(24 * s)
  local fs = math.floor(26 * s)
  local out = {}

  out[#out + 1] = rect(0, by, W, bh, "000000", "50")
  zones.bar = { x = 0, y = by, w = W, h = bh }

  local vol = mp.get_property_number("volume", 100)
  local mute = mp.get_property_bool("mute", false)
  local cy = by + bh / 2
  out[#out + 1] = text(pad, cy, 4, math.floor(30 * s), "FFFFFF", mute and ICON_MUTE or ICON_VOL, ICON_FONT)
  zones.mute = { x = pad, y = by, w = math.floor(40 * s), h = bh }

  local sx = pad + math.floor(56 * s)
  -- La barra de volumen se achica para no encimarse con los botones del centro.
  local sw = math.max(math.floor(40 * s), math.min(math.floor(360 * s), math.floor(W / 2) - math.floor(52 * s) - math.floor(30 * s) - sx - math.floor(90 * s)))
  -- Riel redondeado y perilla circular que nunca se sale del riel ni pisa el porcentaje.
  local sh = math.max(4, math.floor(6 * s))
  local kr = math.floor(9 * s)
  local tx, tw = sx + kr, sw - 2 * kr
  local frac = math.min(vol, 100) / 100
  local ky = math.floor(cy - sh / 2)
  out[#out + 1] = rrect(tx, ky, tw, sh, math.floor(sh / 2), "FFFFFF", "A0")
  if frac > 0 then
    out[#out + 1] = rrect(tx, ky, math.max(sh, math.floor(tw * frac)), sh, math.floor(sh / 2), mute and "888888" or "22D3EE", "00")
  end
  local kx = tx + math.floor(tw * frac)
  out[#out + 1] = rrect(kx - kr, math.floor(cy - kr), kr * 2, kr * 2, kr, "FFFFFF", "00")
  zones.slider = { x = sx, y = by, w = sw, h = bh, tx = tx, tw = tw }
  out[#out + 1] = text(sx + sw + math.floor(14 * s), cy, 4, fs, "FFFFFF", string.format("%d%%", vol))

  -- Centro: captura de pantalla y grabar/detener (con el tiempo mientras graba).
  local bsz = math.floor(30 * s)
  local cxm = math.floor(W / 2)
  local step = math.floor(52 * s)
  -- Los glifos de la fuente no vienen centrados en su caja: se corrigen a ojo (medido en px).
  out[#out + 1] = text(cxm - step - math.floor(4 * s), cy, 5, bsz, "FFFFFF", ICON_CAM, ICON_FONT)
  zones.shot = { x = cxm - step - math.floor(22 * s), y = by, w = math.floor(44 * s), h = bh }
  -- Pausa: ⏸ normal; congelada, ▶ oscuro dentro de un círculo cyan.
  if paused then
    local r = math.floor(17 * s)
    out[#out + 1] = rrect(cxm - r, math.floor(cy - r), 2 * r, 2 * r, r, "22D3EE", "00")
    out[#out + 1] = text(cxm + math.floor(2 * s), cy, 5, math.floor(22 * s), "0B0D12", ICON_PLAY, ICON_FONT)
  else
    out[#out + 1] = text(cxm, cy, 5, math.floor(26 * s), "FFFFFF", ICON_PAUSE, ICON_FONT)
  end
  zones.pause = { x = cxm - math.floor(22 * s), y = by, w = math.floor(44 * s), h = bh }
  out[#out + 1] = text(cxm + step - math.floor((rec and 1 or 4) * s), cy, 5, bsz, "E53935", rec and ICON_STOP or ICON_REC, ICON_FONT)
  zones.rec = { x = cxm + step - math.floor(22 * s), y = by, w = math.floor(44 * s), h = bh }
  if rec then
    local t = math.floor(mp.get_time() - rec.t0)
    out[#out + 1] = text(cxm + step + math.floor(26 * s), cy, 4, math.floor(22 * s), "E53935", string.format("%02d:%02d", math.floor(t / 60), t % 60))
  end

  -- Derecha: estado, engrane, Acerca de y salir.
  local ex = W - pad - math.floor(32 * s)
  out[#out + 1] = text(ex, cy, 4, math.floor(30 * s), "FFFFFF", ICON_EXIT, ICON_FONT)
  zones.exit = { x = ex - math.floor(8 * s), y = by, w = math.floor(48 * s), h = bh }
  local ax = ex - math.floor(50 * s)
  out[#out + 1] = text(ax, cy, 4, math.floor(30 * s), about_open and "22D3EE" or "FFFFFF", ICON_INFO, ICON_FONT)
  zones.about_btn = { x = ax - math.floor(8 * s), y = by, w = math.floor(46 * s), h = bh }
  local gx = ax - math.floor(52 * s)
  out[#out + 1] = text(gx, cy, 4, math.floor(32 * s), menu_open and "22D3EE" or "FFFFFF", ICON_GEAR, ICON_FONT)
  zones.gear = { x = gx - math.floor(8 * s), y = by, w = math.floor(48 * s), h = bh }
  local status = sources[src_current] and (short_name(sources[src_current].name) .. " · " .. preset_name(current)) or L("no_source")
  local free = (gx - math.floor(14 * s)) - (math.floor(W / 2) + math.floor(52 * s) + math.floor((rec and 110 or 30) * s))
  local chars = #status:gsub("[\128-\191]", "")
  if chars * 10 * s > free then
    local maxc = math.floor(free / (10 * s)) - 1
    status = maxc > 6 and (status:sub(1, maxc):gsub("[\192-\255][\128-\191]*$", "") .. "…") or ""
  end
  if status ~= "" then out[#out + 1] = text(gx - math.floor(14 * s), cy, 6, math.floor(20 * s), "CCCCCC", status) end

  if menu_open then
    -- Estilo "lista": panel oscuro recto, sin sombra, iconos cyan, valor a la derecha y la opción elegida
    -- marcada con una franja magenta (los colores del icono).
    local rows = menu_rows()
    local iw, ih = math.floor(460 * s), math.floor(54 * s)
    local mx = W - pad - iw
    local mh = ih * #rows + math.floor(16 * s)
    local my = by - mh - math.floor(10 * s)
    local CYAN, MAGENTA = "22D3EE", "E8179A"
    local DD_ICON = { src = "\u{f03d}", q = "\u{f26c}", lang = "\u{f024}" }
    local fsz = math.floor(21 * s)
    out[#out + 1] = rect(mx, my, iw, mh, "0D0F14", "14")
    zones.items = {}
    local x1, x2, tx = mx + pad, mx + iw - pad, mx + pad + math.floor(38 * s)
    for k, r in ipairs(rows) do
      local iy = my + math.floor(8 * s) + ih * (k - 1)
      local cy2 = iy + ih / 2
      if (r.kind == "dd" and k > 1) or r.kind == "rescan" then
        out[#out + 1] = rect(mx + math.floor(14 * s), iy, iw - math.floor(28 * s), math.max(1, math.floor(s)), "222632", "00")
      end
      if r.kind == "dd" then
        local open = open_dd == r.which
        out[#out + 1] = text(x1, cy2, 4, math.floor(23 * s), CYAN, DD_ICON[r.which], ICON_FONT)
        out[#out + 1] = text(tx, cy2, 4, fsz, "FFFFFF", "{\\b1}" .. r.title)
        out[#out + 1] = text(x2, cy2, 6, math.floor(17 * s), "9AA3B2", open and "\u{f077}" or "\u{f078}", ICON_FONT)
        out[#out + 1] = text(x2 - math.floor(26 * s), cy2, 6, math.floor(19 * s), "9AA3B2", r.value)
      elseif r.kind == "info" then
        out[#out + 1] = text(tx, cy2, 4, math.floor(20 * s), "9AA3B2", r.label)
      elseif r.kind == "opt" then
        if r.on then
          out[#out + 1] = rect(mx, iy, iw, ih, MAGENTA, "D6")
          out[#out + 1] = rect(mx, iy, math.max(3, math.floor(5 * s)), ih, MAGENTA, "00")
        end
        local lx = tx
        if r.flag then
          local fw, fh = math.floor(27 * s), math.floor(18 * s)
          draw_flag(out, r.flag, lx, math.floor(cy2 - fh / 2), fw, fh)
          lx = lx + fw + math.floor(12 * s)
        end
        out[#out + 1] = text(lx, cy2, 4, math.floor(20 * s), r.on and "FFFFFF" or "AEB4C0", r.label)
      elseif r.kind == "rescan" then
        out[#out + 1] = text(x1, cy2, 4, math.floor(23 * s), CYAN, "\u{f021}", ICON_FONT)
        out[#out + 1] = text(tx, cy2, 4, fsz, "FFFFFF", r.label)
      end
      if r.kind ~= "info" then zones.items[#zones.items + 1] = { x = mx, y = iy, w = iw, h = ih, row = r } end
    end
    zones.menu = { x = mx, y = my, w = iw, h = mh }
  end

  if about_open then draw_about(out, s) end
  if quit_open then draw_quit(out, s) end

  ov.data = table.concat(out, "\n")
  ov:update()
end

local function inside(z, x, y)
  return z and x >= z.x and x <= z.x + z.w and y >= z.y and y <= z.y + z.h
end

local function show()
  visible = true
  if hide_timer then hide_timer:kill() end
  hide_timer = mp.add_timeout(2.5, function()
    if not menu_open and not about_open and not quit_open and not dragging then visible = false; render() end
  end)
  render()
end

local function set_from_x(x)
  local z = zones.slider
  if not z then return end
  local v = math.floor(math.max(0, math.min(1, (x - z.tx) / z.tw)) * 100 + 0.5)
  mp.set_property_number("volume", v)
  if v > 0 then mp.set_property_bool("mute", false) end
end

local function apply_quality(i)
  current = i
  mp.set_property("vf", PRESETS[i].vf)
  mp.osd_message(L("quality") .. ": " .. preset_name(i), 1.5)
end

local function rescan()
  local prev = sources[src_current] and sources[src_current].dev
  sources = scan_sources()
  src_current = 0
  for i, s in ipairs(sources) do if s.dev == prev then src_current = i end end
end

-- Muestra la animación "Buscando fuentes…", busca y abre una fuente si no hay ninguna activa.
local function search_and_open()
  start_loading(L("searching"))
  mp.add_timeout(0.8, function()
    rescan()
    if src_current == 0 and sources[1] then
      open_source(1)
    else
      stop_loading()
      if not sources[1] then mp.osd_message(L("no_devices"), 5) end
    end
    show()
  end)
end

local function pick(row)
  if row.kind == "dd" then
    open_dd = open_dd ~= row.which and row.which or nil
    show(); return
  elseif row.kind == "opt" then
    if row.which == "src" then
      if row.i ~= src_current then open_source(row.i) end
    elseif row.which == "q" then
      apply_quality(row.i)
    else
      set_lang(LANGS[row.i])
    end
    open_dd = nil
    show(); return
  elseif row.kind == "rescan" then
    if rec then mp.osd_message(L("stop_first"), 2); return end
    search_and_open()
  elseif row.kind == "about" then
    about_open = true
  end
  menu_open = false; open_dd = nil
  show()
end

mp.add_forced_key_binding("MBTN_LEFT", "capturadora-click", function(e)
  local m = mp.get_property_native("mouse-pos") or {}
  local x, y = m.x or -1, m.y or -1
  if e.event == "up" then dragging = false; show(); return end
  if e.event ~= "down" and e.event ~= "press" then return end
  if quit_open then
    if inside(zones.quit_yes, x, y) then mp.command("quit")
    elseif inside(zones.quit_no, x, y) or not inside(zones.quit, x, y) then quit_open = false; show() end
    return
  end
  if about_open then
    for _, z in ipairs(zones.links or {}) do
      if inside(z, x, y) then open_url(z.url); return end
    end
    if inside(zones.about_close, x, y) or not inside(zones.about, x, y) then close_about(); show() end
    return
  end
  if menu_open and zones.items then
    for _, z in ipairs(zones.items) do
      if inside(z, x, y) then pick(z.row); return end
    end
    if not inside(zones.menu, x, y) and not inside(zones.gear, x, y) and not inside(zones.about_btn, x, y) and not inside(zones.exit, x, y) then
      menu_open = false; open_dd = nil; show()
      if not inside(zones.bar, x, y) then return end -- un clic en la barra cierra el menú y además usa su botón
    end
  end
  if inside(zones.exit, x, y) then menu_open = false; open_dd = nil; quit_open = true; show()
  elseif inside(zones.about_btn, x, y) then menu_open = false; open_dd = nil; about_open = true; show()
  elseif inside(zones.gear, x, y) then menu_open = not menu_open; open_dd = nil; show()
  elseif inside(zones.shot, x, y) then take_screenshot()
  elseif inside(zones.pause, x, y) then toggle_pause(); show()
  elseif inside(zones.rec, x, y) then toggle_rec(); show()
  elseif inside(zones.mute, x, y) then mp.command("cycle mute")
  elseif inside(zones.slider, x, y) then dragging = e.event == "down"; set_from_x(x) end
end, { complex = true })

mp.add_forced_key_binding("MBTN_LEFT_DBL", "capturadora-dbl", function() end)
-- Se cierra con Super+W (Omarchy), no con q.
mp.add_forced_key_binding("q", "capturadora-no-q", function() end)
mp.add_forced_key_binding("Q", "capturadora-no-Q", function() end)
mp.add_forced_key_binding("s", "capturadora-shot", take_screenshot)
mp.add_forced_key_binding("r", "capturadora-rec", function() toggle_rec(); show() end)
mp.add_forced_key_binding("SPACE", "capturadora-pause", function() toggle_pause(); show() end)
mp.add_forced_key_binding("p", "capturadora-pause-p", function() toggle_pause(); show() end)
-- Sin pantalla completa propia: Omarchy ya la tiene.
mp.add_forced_key_binding("f", "capturadora-no-f", function() end)
mp.add_forced_key_binding("WHEEL_UP", "capturadora-vol-up", function() mp.command("add volume 5"); show() end)
mp.add_forced_key_binding("WHEEL_DOWN", "capturadora-vol-down", function() mp.command("add volume -5"); show() end)
mp.add_forced_key_binding("ESC", "capturadora-esc", function()
  if quit_open then quit_open = false; show()
  elseif about_open then close_about(); show()
  elseif menu_open then menu_open = false; open_dd = nil; show() end
end)

mp.add_forced_key_binding("ENTER", "capturadora-quit-yes", function()
  if quit_open then mp.command("quit") end
end)

mp.observe_property("mouse-pos", "native", function(_, m)
  if not m then return end
  if dragging then set_from_x(m.x) end
  if m.hover then show() end
end)
mp.observe_property("volume", "number", function() apply_volume(); render() end)
mp.observe_property("mute", "bool", function() apply_volume(); render() end)
mp.observe_property("osd-dimensions", "native", render)

mp.register_event("end-file", function(e)
  if rec then return end -- durante la grabación lo maneja finish_rec
  -- Solo cuando se corta la fuente actual (error o ffmpeg terminó), no al cambiarla a propósito.
  if (e.reason == "error" or e.reason == "eof") and view_entry and e.playlist_entry_id == view_entry and sources[src_current] then
    stop_view()
    stop_audio()
    stop_loading()
    -- Vuelve al fondo de espera para que la ventana no se cierre.
    mp.set_property_native("demuxer-lavf-o", {})
    mp.set_property_native("audio-files", {})
    mp.commandv("loadfile", PLACEHOLDER, "replace")
    mp.osd_message(string.format(L("no_signal"), short_name(sources[src_current].name)), 6)
    show()
  end
end)

-- Quita la animación cuando ya hay imagen de una fuente real (no del fondo de espera).
-- Al abrir, mpv junta cuadros mientras arranca y, como el monitor va a los mismos fps que la fuente,
-- nunca recupera ese atraso: un segundo después se vacían sus búferes para mostrar la imagen al día.
local drop_timer
mp.register_event("start-file", function() if drop_timer then drop_timer:kill(); drop_timer = nil end end)
mp.register_event("playback-restart", function()
  if not live() then return end
  stop_loading()
  if drop_timer then return end
  drop_timer = mp.add_timeout(1, function() if live() then mp.command("drop-buffers") end end)
end)

-- Al cerrar la ventana (Super+W) durante una grabación, se detiene ffmpeg para no perderla.
mp.register_event("shutdown", function()
  stop_view()
  stop_audio()
  os.remove(VIEW_LOGF); os.remove(VIEW_DIR)
  local pid = rec and rec_pid()
  if pid then
    run({ "sh", "-c", 'kill -INT "$0"; for i in $(seq 40); do kill -0 "$0" 2>/dev/null || exit 0; sleep 0.1; done', pid })
  end
end)

-- Arranque: abre la primera fuente (la Cam Link si está conectada).
search_and_open()
show()
