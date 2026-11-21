-- Capturzilla HD: barra inferior de volumen y engrane con menú de fuente y calidad para mpv.
local utils = require "mp.utils"

local ICON_FONT = "JetBrainsMono Nerd Font"
local ICON_VOL, ICON_MUTE, ICON_GEAR = "\u{f028}", "\u{f026}", "\u{f013}"
local ICON_CAM, ICON_REC, ICON_STOP = "\u{f030}", "\u{f111}", "\u{f04d}"

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
    rec_starting = "Iniciando grabación…" },
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
    rec_starting = "Starting recording…" },
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
    rec_starting = "Начинаем запись…" },
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
    rec_starting = "Починаємо запис…" },
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
  local list, name = {}, nil
  for line in run({ "v4l2-ctl", "--list-devices" }):gmatch("[^\n]+") do
    if not line:match("^%s") then
      name = line:gsub("%s*%(.*$", ""):gsub(":.*$", "")
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
        list[#list + 1] = { name = name, dev = dev, mode = best }
      end
      name = nil -- solo el primer /dev/video de cada dispositivo captura imagen
    end
  end
  -- Audio del mismo dispositivo, si existe (p. ej. "Cam Link" -> ...Cam_Link...).
  local pulse = run({ "pactl", "list", "short", "sources" })
  for _, s in ipairs(list) do
    local key = s.name:gsub(" ", "_")
    for l in pulse:gmatch("[^\n]+") do
      local id = l:match("^%d+%s+(%S+)")
      if id and not id:match("%.monitor$") and id:find(key, 1, true) then s.audio = id; break end
    end
  end
  table.sort(list, function(a, b) -- la Cam Link primero
    local ca, cb = a.name:find("Cam Link") ~= nil, b.name:find("Cam Link") ~= nil
    if ca ~= cb then return ca end
    return a.dev < b.dev
  end)
  return list
end

local function src_label(s)
  return string.format("%s · %dp %d fps", s.name, s.mode.h, s.mode.fps)
end

-- Animación de carga (GIF del dinosaurio, 4 cuadros BGRA premultiplicados de 200x256).
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

local function open_source(i)
  local s = sources[i]
  if not s then return end
  if rec then mp.osd_message(L("stop_first"), 2); return end
  src_current = i
  start_loading(L("loading"))
  mp.set_property_native("demuxer-lavf-o", {
    video_size = s.mode.w .. "x" .. s.mode.h,
    framerate = tostring(s.mode.fps),
    input_format = s.mode.fmt == "YUYV" and "yuyv422" or "mjpeg",
  })
  mp.set_property_native("audio-files", s.audio and { "av://pulse:" .. s.audio } or {})
  mp.commandv("loadfile", "av://v4l2:" .. s.dev, "replace")
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

local function short_path(f) return (f:gsub("^" .. (os.getenv("HOME") or "~"):gsub("%p", "%%%0"), "~")) end
local function stamp() return os.date("Capturzilla_%Y-%m-%d_%H-%M-%S") end
local function live()
  local p = mp.get_property("path") or ""
  return p:find("^av://v4l2") ~= nil or p == FIFO
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
    math.floor(20 * h / 1080 + 10), math.floor(20 * h / 1080 + 10), math.floor(math.max(18, 30 * h / 1080)), ICON_FONT, ICON_REC, math.floor(t / 60), t % 60)
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
  if s.audio then add("-f", "pulse", "-i", s.audio) end
  add("-map", "0:v")
  if s.audio then add("-map", "1:a", "-c:a", "aac", "-b:a", "192k") end
  add("-vf", "format=yuv420p", "-c:v", "h264_nvenc", "-preset", "p5", "-tune", "hq", "-rc", "vbr", "-cq", "19", "-b:v", "0",
    "-movflags", "+frag_keyframe+empty_moov+default_base_moof", file,
    "-map", "0:v", "-c:v", "rawvideo", "-f", "nut", FIFO)
  rec = { file = file, t0 = mp.get_time() }
  start_loading(L("rec_starting"))
  -- mpv suelta la capturadora y espera la imagen por el FIFO; luego arranca ffmpeg.
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
        local f = io.open(FIFO, "w"); if f then f:close() end
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

local function text(x, y, an, size, color, s, font)
  return string.format("{\\an%d\\pos(%d,%d)\\fs%d\\bord0\\shad0\\1c%s%s}%s",
    an, x, y, size, col(color), font and ("\\fn" .. font) or "", s)
end

-- Ventana "Acerca de" (mismo contenido que el de BT Device Battery Info).
local VERSION = "1.0.0"
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

local function menu_rows()
  local rows = {}
  local function dd(which, title, value)
    rows[#rows + 1] = { kind = "dd", which = which, label = title .. ": " .. value .. (open_dd == which and "  ▴" or "  ▾") }
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
  rows[#rows + 1] = { kind = "about", label = L("about") }
  return rows
end

render = function()
  local d = mp.get_property_native("osd-dimensions") or {}
  W, H = d.w or W, d.h or H
  ov.res_x, ov.res_y = W, H
  zones = {}
  if not visible and not menu_open and not about_open then ov.data = ""; ov:update(); return end

  local s = math.max(0.6, H / 1080)
  local bh = math.floor(64 * s)
  local by = H - bh
  local pad = math.floor(24 * s)
  local fs = math.floor(26 * s)
  local out = {}

  out[#out + 1] = rect(0, by, W, bh, "000000", "50")

  local vol = mp.get_property_number("volume", 100)
  local mute = mp.get_property_bool("mute", false)
  local cy = by + bh / 2
  out[#out + 1] = text(pad, cy, 4, math.floor(30 * s), "FFFFFF", mute and ICON_MUTE or ICON_VOL, ICON_FONT)
  zones.mute = { x = pad, y = by, w = math.floor(40 * s), h = bh }

  local sx = pad + math.floor(56 * s)
  local sw = math.min(math.floor(360 * s), W - sx - math.floor(220 * s))
  local sh = math.floor(6 * s)
  local frac = math.min(vol, 100) / 100
  out[#out + 1] = rect(sx, cy - sh / 2, sw, sh, "FFFFFF", "A0")
  out[#out + 1] = rect(sx, cy - sh / 2, math.floor(sw * frac), sh, mute and "888888" or "4FA3FF", "00")
  local kr = math.floor(9 * s)
  out[#out + 1] = rect(sx + math.floor(sw * frac) - kr, cy - kr, kr * 2, kr * 2, "FFFFFF", "00")
  zones.slider = { x = sx, y = by, w = sw, h = bh }
  out[#out + 1] = text(sx + sw + math.floor(16 * s), cy, 4, fs, "FFFFFF", string.format("%d%%", vol))

  -- Centro: captura de pantalla y grabar/detener (con el tiempo mientras graba).
  local bsz = math.floor(30 * s)
  local cxm = math.floor(W / 2)
  out[#out + 1] = text(cxm - math.floor(34 * s), cy, 5, bsz, "FFFFFF", ICON_CAM, ICON_FONT)
  zones.shot = { x = cxm - math.floor(56 * s), y = by, w = math.floor(44 * s), h = bh }
  out[#out + 1] = text(cxm + math.floor(26 * s), cy, 5, bsz, "E53935", rec and ICON_STOP or ICON_REC, ICON_FONT)
  zones.rec = { x = cxm + math.floor(4 * s), y = by, w = math.floor(44 * s), h = bh }
  if rec then
    local t = math.floor(mp.get_time() - rec.t0)
    out[#out + 1] = text(cxm + math.floor(52 * s), cy, 4, math.floor(22 * s), "E53935", string.format("%02d:%02d", math.floor(t / 60), t % 60))
  end

  local gx = W - pad - math.floor(36 * s)
  out[#out + 1] = text(gx, cy, 4, math.floor(32 * s), menu_open and "4FA3FF" or "FFFFFF", ICON_GEAR, ICON_FONT)
  local status = sources[src_current] and (sources[src_current].name .. " · " .. preset_name(current)) or L("no_source")
  out[#out + 1] = text(gx - math.floor(14 * s), cy, 6, math.floor(20 * s), "CCCCCC", status)
  zones.gear = { x = gx - math.floor(8 * s), y = by, w = math.floor(56 * s), h = bh }

  if menu_open then
    local rows = menu_rows()
    local iw, ih = math.floor(420 * s), math.floor(50 * s)
    local mx = W - pad - iw
    local mh = ih * #rows
    local my = by - mh - math.floor(8 * s)
    out[#out + 1] = rect(mx, my, iw, mh, "15181E", "18")
    zones.items = {}
    for k, r in ipairs(rows) do
      local iy = my + ih * (k - 1)
      if r.kind == "header" then
        out[#out + 1] = text(mx + pad, iy + ih / 2, 4, math.floor(19 * s), "9AA3B2", r.label)
      elseif r.kind == "info" then
        out[#out + 1] = text(mx + pad, iy + ih / 2, 4, math.floor(22 * s), "CCCCCC", r.label)
      else
        if r.kind == "opt" then out[#out + 1] = rect(mx, iy, iw, ih, "262B35", "00") end
        if r.on then out[#out + 1] = rect(mx, iy, iw, ih, "4FA3FF", "B0") end
        local DD_MARK = { src = "▣ ", q = "◈ ", lang = "⚑ " }
        local mark = r.kind == "rescan" and "↻ " or r.kind == "about" and "ⓘ " or r.kind == "dd" and DD_MARK[r.which] or (r.on and "● " or "○ ")
        local indent = r.kind == "opt" and math.floor(28 * s) or 0
        if r.flag then -- bandera justo a la izquierda del nombre del idioma: "○ [bandera] Español"
          local fw, fh = math.floor(27 * s), math.floor(18 * s)
          local fx = mx + pad + indent + math.floor(26 * s)
          out[#out + 1] = text(mx + pad + indent, iy + ih / 2, 4, math.floor(24 * s), "FFFFFF", mark)
          draw_flag(out, r.flag, fx, math.floor(iy + (ih - fh) / 2), fw, fh)
          out[#out + 1] = text(fx + fw + math.floor(10 * s), iy + ih / 2, 4, math.floor(24 * s), "FFFFFF", r.label)
        else
          out[#out + 1] = text(mx + pad + indent, iy + ih / 2, 4, math.floor(24 * s), "FFFFFF", mark .. r.label)
        end
        zones.items[#zones.items + 1] = { x = mx, y = iy, w = iw, h = ih, row = r }
      end
    end
    zones.menu = { x = mx, y = my, w = iw, h = mh }
  end

  if about_open then draw_about(out, s) end

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
    if not menu_open and not about_open and not dragging then visible = false; render() end
  end)
  render()
end

local function set_from_x(x)
  local z = zones.slider
  if not z then return end
  local v = math.floor(math.max(0, math.min(1, (x - z.x) / z.w)) * 100 + 0.5)
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
    if not inside(zones.menu, x, y) and not inside(zones.gear, x, y) then menu_open = false; open_dd = nil; show(); return end
  end
  if inside(zones.gear, x, y) then menu_open = not menu_open; open_dd = nil; show()
  elseif inside(zones.shot, x, y) then take_screenshot()
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
-- Sin pantalla completa propia: Omarchy ya la tiene.
mp.add_forced_key_binding("f", "capturadora-no-f", function() end)
mp.add_forced_key_binding("WHEEL_UP", "capturadora-vol-up", function() mp.command("add volume 5"); show() end)
mp.add_forced_key_binding("WHEEL_DOWN", "capturadora-vol-down", function() mp.command("add volume -5"); show() end)
mp.add_forced_key_binding("ESC", "capturadora-esc", function()
  if about_open then close_about(); show()
  elseif menu_open then menu_open = false; open_dd = nil; show() end
end)

mp.observe_property("mouse-pos", "native", function(_, m)
  if not m then return end
  if dragging then set_from_x(m.x) end
  if m.hover then show() end
end)
mp.observe_property("volume", "number", render)
mp.observe_property("mute", "bool", render)
mp.observe_property("osd-dimensions", "native", render)

mp.register_event("end-file", function(e)
  if rec then return end -- durante la grabación lo maneja finish_rec
  if e.reason == "error" and sources[src_current] then
    stop_loading()
    -- Vuelve al fondo de espera para que la ventana no se cierre.
    mp.set_property_native("demuxer-lavf-o", {})
    mp.set_property_native("audio-files", {})
    mp.commandv("loadfile", PLACEHOLDER, "replace")
    mp.osd_message(string.format(L("no_signal"), sources[src_current].name), 6)
    show()
  end
end)

-- Quita la animación cuando ya hay imagen de una fuente real (no del fondo de espera).
mp.register_event("playback-restart", function()
  if live() then stop_loading() end
end)

-- Al cerrar la ventana (Super+W) durante una grabación, se detiene ffmpeg para no perderla.
mp.register_event("shutdown", function()
  local pid = rec and rec_pid()
  if pid then
    run({ "sh", "-c", 'kill -INT "$0"; for i in $(seq 40); do kill -0 "$0" 2>/dev/null || exit 0; sleep 0.1; done', pid })
  end
end)

-- Arranque: abre la primera fuente (la Cam Link si está conectada).
search_and_open()
show()
