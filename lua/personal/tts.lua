-- ~/.config/nvim/lua/personal/tts.lua
-- Text-to-speech: read the visual selection (or word under cursor) aloud,
-- auto-detecting the language. Trigger with <Leader>tp while text is selected
-- (mouse or keyboard); right-click is left untouched so its popup menu works.
--
-- Engines:
--   * "piper"  - local neural TTS (piper-tts, natural voices). Voice models are
--                downloaded on demand with :TtsDownloadVoice <voice>.
--   * "edge"   - edge-tts (Microsoft neural voices, needs network). Covers
--                languages piper has no voice for, incl. Korean/Japanese/Arabic.
--   * "spd-say" - speech-dispatcher (espeak-ng; robotic, huge language coverage)
--                 and the last-resort fallback.
--
-- engine "auto" (default) tries piper -> edge -> spd-say per language.

local M = {}

M.config = {
  engine = "auto",        -- "auto" | "piper" | "edge" | "spd-say"
  default_lang = "en",    -- fallback when detection is inconclusive
  cancel_previous = true, -- stop any currently playing speech first
  rate = 0,               -- spd-say: -100 .. +100
  pitch = 0,              -- spd-say: -100 .. +100
  volume = 100,           -- spd-say: -100 .. +100
  piper = {
    bin = vim.fn.expand("~/.local/share/piper-venv/bin/piper"),
    voice_dir = vim.fn.expand("~/.local/share/piper-voices"),
    default_voice = "en_US-lessac-medium",
    auto_download = false, -- auto-download the voice if missing (needs curl)
  },
  edge = {
    bin = vim.fn.expand("~/.local/share/piper-venv/bin/edge-tts"),
  },
  -- Detected ISO language -> piper voice id (see rhasspy/piper-voices).
  -- Languages without a piper voice fall back to edge-tts, then spd-say.
  voices = {
    en = "en_US-lessac-medium",
    de = "de_DE-thorsten-medium",
    fr = "fr_FR-siwis-medium",
    es = "es_ES-davefx-medium",
    pt = "pt_BR-faber-medium",
    it = "it_IT-riccardo-x_low",
    nl = "nl_NL-mls-medium",
    sv = "sv_SE-nst-medium",
    da = "da_DK-talesyntese-medium",
    fi = "fi_FI-harri-medium",
    pl = "pl_PL-darkman-medium",
    cs = "cs_CZ-jirka-medium",
    sk = "sk_SK-lili-medium",
    sl = "sl_SI-artur-medium",
    hu = "hu_HU-anna-medium",
    ro = "ro_RO-mihai-medium",
    tr = "tr_TR-fettah-medium",
    ru = "ru_RU-irina-medium",
    uk = "uk_UA-ukrainian_tts-medium",
    vi = "vi_VN-vais1000-medium",
    zh = "zh_CN-huayan-medium",
  },
  -- Detected ISO language -> edge-tts neural voice. Used when piper has no
  -- voice for the language (edge-tts covers ~130 locales, needs network).
  edge_voices = {
    ko = "ko-KR-SunHiNeural",
    ja = "ja-JP-NanamiNeural",
    el = "el-GR-AthinaNeural",
    hr = "hr-HR-GabrijelaNeural",
    ar = "ar-SA-ZariyahNeural",
    hi = "hi-IN-SwaraNeural",
    he = "he-IL-AvriNeural",
    th = "th-TH-PremwadeeNeural",
    fa = "fa-IR-DilaraNeural",
    id = "id-ID-GadisNeural",
    ms = "ms-MY-YasminNeural",
    sr = "sr-RS-SophieNeural",
    et = "et-EE-AnuNeural",
    lv = "lv-LV-EveritaNeural",
    lt = "lt-LT-OnaNeural",
    hy = "hy-AM-AnahitNeural",
    ka = "ka-GE-EkaNeural",
    kk = "kk-KZ-AigulNeural",
    az = "az-AZ-BabekNeural",
    uz = "uz-UZ-MadinaNeural",
    bn = "bn-BD-NabanitaNeural",
    ta = "ta-IN-PallaviNeural",
    te = "te-IN-ShrutiNeural",
    kn = "kn-IN-GaganNeural",
    ml = "ml-IN-SobhanaNeural",
    mr = "mr-IN-AarohiNeural",
    gu = "gu-IN-NiranjanNeural",
    pa = "pa-IN-BaljeetNeural",
    sw = "sw-KE-ZuriNeural",
    fil = "fil-PH-BlessicaNeural",
    bg = "bg-BG-KalinaNeural",
    cy = "cy-GB-NiaNeural",
    ca = "ca-ES-JoanaNeural",
    sq = "sq-AL-AnilaNeural",
    mt = "mt-MT-GraceNeural",
    mk = "mk-MK-MarijaNeural",
    bs = "bs-BA-VesnaNeural",
    is = "is-IS-GudrunNeural",
    ga = "ga-IE-OrlaNeural",
    eu = "eu-ES-AinhoaNeural",
    gl = "gl-ES-SabelaNeural",
    ha = "ha-NG-AminuNeural",
    af = "af-ZA-AdriNeural",
    am = "am-ET-MekdesNeural",
    zu = "zu-ZA-ThandoNeural",
    xh = "xh-ZA-ThandoNeural",
    wo = "wo-SN-MariamaNeural",
    ig = "ig-NG-ChinweNeural",
    yo = "yo-NG-AkinNeural",
    so = "so-SO-MuuseNeural",
  },
}

local VOICES_REPO = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0"

-- Distinctive diacritics per language (Latin script). First match wins a tie.
local DIACRITIC_HINTS = {
  pl = { "ł", "Ł" },
  cs = { "ě", "ř", "ů" },
  sk = { "ľ", "ĺ", "ŕ" },
  hr = { "đ", "Đ", "ć", "Ć" },
  tr = { "ğ", "ş", "ı", "ö", "ü", "ç" },
  ro = { "ă", "Ă", "ș", "Ș", "ț", "Ț" },
  hu = { "ő", "ű" },
  vi = { "đ", "ơ", "ư", "ộ" },
  sv = { "å", "Å", "ä", "ö" },
  da = { "æ", "ø", "å" },
  no = { "æ", "ø", "å" },
  fr = { "à", "â", "ç", "é", "è", "ê", "ë", "î", "ï", "ô", "œ", "ù", "û", "ü" },
  de = { "ä", "ö", "ü", "ß" },
  es = { "á", "é", "í", "ó", "ú", "ñ", "¿", "¡" },
  pt = { "ã", "õ", "ç", "á", "é", "í", "ó", "ú", "â", "ê", "ô" },
  it = { "à", "è", "é", "ì", "ò", "ù" },
  nl = { "ë", "ï" },
  sl = { "č", "š", "ž" },
}

-- Very common words per language. Score = matched occurrences (lowercased).
local STOPWORDS = {
  en = { "the", "and", "of", "to", "is", "that", "you", "it", "with", "this", "are", "have" },
  de = { "und", "der", "die", "das", "ist", "nicht", "mit", "auch", "ein", "eine", "den", "auf" },
  fr = { "le", "la", "les", "et", "est", "des", "de", "un", "une", "pour", "dans", "que" },
  es = { "el", "la", "los", "las", "y", "es", "de", "un", "una", "que", "en", "por" },
  pt = { "o", "a", "os", "as", "e", "de", "que", "um", "uma", "em", "para", "não" },
  it = { "il", "lo", "la", "gli", "e", "di", "che", "un", "una", "per", "in", "non" },
  nl = { "de", "het", "een", "en", "van", "is", "dat", "niet", "met", "voor", "op" },
  sv = { "och", "det", "att", "en", "ett", "som", "är", "inte", "för", "med", "på" },
  da = { "og", "det", "at", "en", "er", "som", "ikke", "med", "på", "til" },
  no = { "og", "det", "at", "en", "er", "som", "ikke", "med", "på", "til" },
  fi = { "ja", "on", "ei", "että", "se", "hän", "olla", "ole", "kun", "kuin" },
  pl = { "i", "w", "jest", "na", "nie", "to", "się", "z", "do", "że", "jak" },
  cs = { "a", "je", "se", "na", "v", "že", "to", "který", "jak", "pro" },
  sk = { "a", "je", "sa", "na", "v", "že", "to", "ktorý", "ako", "pre" },
  sl = { "in", "je", "se", "na", "za", "so", "ki", "da", "pri", "kot" },
  hr = { "i", "je", "se", "na", "za", "s", "a", "da", "koji", "kao" },
  hu = { "és", "a", "az", "hogy", "nem", "egy", "van", "de", "is", "meg" },
  ro = { "și", "este", "în", "de", "un", "o", "la", "cu", "pentru", "că" },
  tr = { "ve", "bir", "bu", "için", "ile", "olarak", "da", "de", "ne", "o" },
  vi = { "và", "là", "của", "có", "không", "được", "các", "để", "trong", "một" },
}

-- Ukrainian-specific codepoints: і ї є ґ / І Ї Є Ґ
local UKRAINIAN = {
  [0x0456] = true, [0x0457] = true, [0x0454] = true, [0x0491] = true,
  [0x0406] = true, [0x0407] = true, [0x0404] = true, [0x0490] = true,
}

-- Persian-specific letters (shared with Urdu, but Urdu is rare): پ چ ژ گ
local PERSIAN = {
  [0x067E] = true, [0x0686] = true, [0x0698] = true, [0x06AF] = true,
}

-- Returns a language code for non-Latin scripts, or nil.
local function detect_script(text)
  local han, kana, hangul, cyrillic, greek, arabic, hebrew, thai, devanagari = 0, 0, 0, 0, 0, 0, 0, 0, 0
  local ukrainian, persian = false, false
  local total = 0
  local nchars = vim.fn.strcharlen(text)
  for i = 1, nchars do
    local cp = vim.fn.strgetchar(text, i)
    if cp >= 0 then
      total = total + 1
      if cp >= 0x4E00 and cp <= 0x9FFF or cp >= 0x3400 and cp <= 0x4DBF then
        han = han + 1
      elseif cp >= 0x3040 and cp <= 0x30FF or cp >= 0x31F0 and cp <= 0x31FF then
        kana = kana + 1
      elseif cp >= 0xAC00 and cp <= 0xD7AF or cp >= 0x1100 and cp <= 0x11FF then
        hangul = hangul + 1
      elseif cp >= 0x0400 and cp <= 0x04FF or cp >= 0x0500 and cp <= 0x052F then
        cyrillic = cyrillic + 1
        if UKRAINIAN[cp] then
          ukrainian = true
        end
      elseif cp >= 0x0370 and cp <= 0x03FF then
        greek = greek + 1
      elseif cp >= 0x0600 and cp <= 0x06FF or cp >= 0x0750 and cp <= 0x077F then
        arabic = arabic + 1
        if PERSIAN[cp] then
          persian = true
        end
      elseif cp >= 0x0590 and cp <= 0x05FF then
        hebrew = hebrew + 1
      elseif cp >= 0x0E00 and cp <= 0x0E7F then
        thai = thai + 1
      elseif cp >= 0x0900 and cp <= 0x097F then
        devanagari = devanagari + 1
      end
    end
  end
  if total == 0 then
    return nil
  end
  if han > 0 then
    if kana > han / 4 then return "ja" end
    if hangul > han / 4 then return "ko" end
    return "zh"
  end
  if kana > 0 then return "ja" end
  if hangul > 0 then return "ko" end
  if cyrillic > 0 then
    if ukrainian then return "uk" end
    return "ru"
  end
  if greek > 0 then return "el" end
  if arabic > 0 then
    if persian then return "fa" end
    return "ar"
  end
  if hebrew > 0 then return "he" end
  if thai > 0 then return "th" end
  if devanagari > 0 then return "hi" end
  return nil
end

-- Latin script: score stopwords + distinctive diacritics.
local function detect_latin_lang(text)
  local lower = text:lower()
  local words = {}
  for w in lower:gmatch("[a-zà-ÿ'’-]+") do
    words[#words + 1] = w
  end

  local best_lang, best_score = nil, -1
  for lang, stops in pairs(STOPWORDS) do
    local score = 0
    local stopset = {}
    for _, s in ipairs(stops) do
      stopset[s] = true
    end
    for _, w in ipairs(words) do
      if stopset[w] then
        score = score + 1
      end
    end
    local hints = DIACRITIC_HINTS[lang]
    if hints then
      for _, ch in ipairs(hints) do
        if text:find(ch, 1, true) then
          score = score + 2
        end
      end
    end
    if score > best_score then
      best_lang, best_score = lang, score
    end
  end
  return best_score > 0 and best_lang or nil
end

-- Public: detect the ISO language code of a piece of text.
function M.detect_language(text)
  if type(text) ~= "string" or text == "" then
    return M.config.default_lang
  end
  local script_lang = detect_script(text)
  if script_lang then
    return script_lang
  end
  return detect_latin_lang(text) or M.config.default_lang
end

-- ---------------------------------------------------------------------------
-- Engines
-- ---------------------------------------------------------------------------

-- Currently running speech jobs (piper/edge synthesis + player). Killed when a
-- new speak starts so the old block's audio never plays behind the new one.
local next_job_id = 0
local active_jobs = {} -- id -> SystemObj
local cancelled = {}   -- ids intentionally killed (no failure notify)

local function track_job(job)
  next_job_id = next_job_id + 1
  active_jobs[next_job_id] = job
  return next_job_id
end

local function untrack_job(id)
  active_jobs[id] = nil
end

local function cancel_playback()
  for id, job in pairs(active_jobs) do
    cancelled[id] = true
    pcall(function()
      job:kill(15) -- SIGTERM
    end)
  end
  active_jobs = {}
  if vim.fn.executable("spd-say") == 1 then
    vim.system({ "spd-say", "-C" }) -- cancel queued spd-say speech
  end
end

-- Build the onnx + json file paths for a piper voice id.
local function piper_voice_files(voice)
  local dir = M.config.piper.voice_dir
  return dir .. "/" .. voice .. ".onnx", dir .. "/" .. voice .. ".onnx.json"
end

-- Derive the HuggingFace path inside rhasspy/piper-voices for a voice id
-- like "en_US-lessac-medium" -> en/en_US/lessac/medium/en_US-lessac-medium.
local function piper_voice_hf_path(voice)
  local locale, rest = voice:match("^(%a%a_%a%a)%-(.+)$")
  if not locale then
    return nil
  end
  local name, quality = rest:match("^(.*)%-(.*)$")
  if not name then
    return nil
  end
  local lang = locale:match("^(%a%a)")
  return lang .. "/" .. locale .. "/" .. name .. "/" .. quality .. "/" .. voice
end

local function voice_lang(voice)
  return voice:match("^(%a%a)_")
end

-- Download a piper voice (model + config) into the voice dir.
function M.download_voice(voice, cb)
  if not voice or voice == "" then
    voice = M.config.piper.default_voice
  end
  if vim.fn.executable("curl") == 0 then
    vim.notify("TTS: 'curl' not found, cannot download voices", vim.log.levels.ERROR)
    return
  end
  local hf = piper_voice_hf_path(voice)
  if not hf then
    vim.notify("TTS: invalid voice id '" .. voice .. "' (expected ll_XX-name-quality)", vim.log.levels.ERROR)
    return
  end
  vim.fn.mkdir(M.config.piper.voice_dir, "p")
  local onnx, json = piper_voice_files(voice)
  vim.notify("TTS: downloading voice '" .. voice .. "' ...", vim.log.levels.INFO)
  local function fetch(url, dest)
    vim.system({ "curl", "-sL", "-o", dest, url }, nil, function(obj)
      if obj.code ~= 0 then
        vim.schedule(function()
          vim.notify("TTS: failed to download " .. dest, vim.log.levels.ERROR)
        end)
      end
    end)
  end
  fetch(VOICES_REPO .. "/" .. hf .. ".onnx", onnx)
  fetch(VOICES_REPO .. "/" .. hf .. ".onnx.json", json)
  M.set_voice(voice)
  if cb then
    cb(voice)
  end
end

-- Select the default piper voice and map it to its language.
function M.set_voice(voice)
  M.config.piper.default_voice = voice
  local lang = voice_lang(voice)
  if lang then
    M.config.voices[lang] = voice
  end
end

-- Forward declaration: the piper/edge failure callbacks fall back to spd-say,
-- but speak_spd is defined later in this file.
local speak_spd

-- Speak via piper (neural). Returns true when it accepted the job.
local function speak_piper(text, lang)
  local piper_bin = M.config.piper.bin
  if vim.fn.executable(piper_bin) == 0 then
    vim.notify("TTS: piper not found at " .. piper_bin, vim.log.levels.WARN)
    return false
  end
  local voice = M.config.voices[lang]
  if not voice then
    -- No piper voice for this language: fall back to spd-say instead of
    -- reading it with the wrong voice.
    return false
  end
  local onnx, json = piper_voice_files(voice)
  if vim.fn.filereadable(onnx) == 0 or vim.fn.filereadable(json) == 0 then
    if M.config.piper.auto_download and vim.fn.executable("curl") == 1 then
      vim.notify("TTS: downloading voice '" .. voice .. "' ...", vim.log.levels.INFO)
      M.download_voice(voice)
    else
      vim.notify(
        "TTS: voice '" .. voice .. "' not downloaded. Run :TtsDownloadVoice " .. voice .. " (falling back to spd-say)",
        vim.log.levels.WARN
      )
    end
    return false
  end

  local out = vim.fn.tempname() .. ".wav"
  local player = "paplay"
  if vim.fn.executable(player) == 0 then
    player = "aplay"
  end
  local args = { piper_bin, "-m", onnx, "-c", json, "-f", out }
  local synth_id = nil
  local synth = vim.system(args, { stdin = text, text = true }, function(obj)
    if not cancelled[synth_id] and obj.code ~= 0 then
      local err = obj.stderr and obj.stderr:gsub("%s+$", "") or ""
      vim.schedule(function()
        vim.notify(
          "TTS: piper failed (exit " .. tostring(obj.code) .. ") " .. err,
          vim.log.levels.WARN
        )
        -- async failure: fall back to spd-say so there is still sound
        speak_spd(text, lang)
      end)
    end
    untrack_job(synth_id)
    if obj.code ~= 0 then
      os.remove(out)
      return
    end
    local play_id = nil
    local play = vim.system({ player, out }, nil, function()
      if not cancelled[play_id] then
        -- normal completion; nothing to do
      end
      untrack_job(play_id)
      os.remove(out)
    end)
    play_id = track_job(play)
  end)
  synth_id = track_job(synth)
  return true
end

-- Speak via edge-tts (Microsoft neural voices; needs network).
-- Produces an MP3 and plays it with ffplay (paplay cannot decode mp3).
local function speak_edge(text, lang)
  local edge_bin = M.config.edge.bin
  if vim.fn.executable(edge_bin) == 0 then
    return false
  end
  local voice = M.config.edge_voices[lang]
  if not voice then
    return false
  end
  local out = vim.fn.tempname() .. ".mp3"
  local args = { edge_bin, "--voice", voice, "--text", text, "--write-media", out }
  local synth_id = nil
  local synth = vim.system(args, { text = true }, function(obj)
    if not cancelled[synth_id] and obj.code ~= 0 then
      local err = obj.stderr and obj.stderr:gsub("%s+$", "") or ""
      vim.schedule(function()
        vim.notify(
          "TTS: edge-tts failed (exit " .. tostring(obj.code) .. ") " .. err,
          vim.log.levels.WARN
        )
        -- async failure: fall back to spd-say so there is still sound
        speak_spd(text, lang)
      end)
    end
    untrack_job(synth_id)
    if obj.code ~= 0 then
      os.remove(out)
      return
    end
    local play_id = nil
    local play = vim.system({ "ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", out }, nil, function()
      untrack_job(play_id)
      os.remove(out)
    end)
    play_id = track_job(play)
  end)
  synth_id = track_job(synth)
  return true
end

-- Speak via speech-dispatcher (robotic, broad language coverage).
speak_spd = function(text, lang)
  if vim.fn.executable("spd-say") == 0 then
    vim.notify("TTS: 'spd-say' not found. Install speech-dispatcher.", vim.log.levels.ERROR)
    return false
  end
  local args = { "spd-say" }
  if M.config.rate ~= 0 then
    args[#args + 1] = "-r"
    args[#args + 1] = tostring(M.config.rate)
  end
  if M.config.pitch ~= 0 then
    args[#args + 1] = "-p"
    args[#args + 1] = tostring(M.config.pitch)
  end
  if M.config.volume ~= 0 then
    args[#args + 1] = "-i"
    args[#args + 1] = tostring(M.config.volume)
  end
  args[#args + 1] = "-l"
  args[#args + 1] = lang
  args[#args + 1] = "-N"
  args[#args + 1] = "nvim"
  args[#args + 1] = text

  vim.system(args, nil, function(obj)
    if obj.code ~= 0 then
      vim.schedule(function()
        vim.notify("TTS: spd-say failed (exit " .. tostring(obj.code) .. ")", vim.log.levels.WARN)
      end)
    end
  end)
  return true
end

-- Public: speak text aloud with the given (or auto-detected) language.
-- Engine precedence ("auto"): piper -> edge-tts -> spd-say, per language.
function M.speak(text, lang)
  if type(text) ~= "string" or text == "" then
    return false
  end
  lang = lang or M.detect_language(text)

  if M.config.cancel_previous then
    cancel_playback()
  end

  local e = M.config.engine
  if e == "spd-say" then
    return speak_spd(text, lang)
  end
  if e == "piper" or e == "auto" then
    if speak_piper(text, lang) then
      return true
    end
  end
  if e == "edge" or e == "auto" then
    if speak_edge(text, lang) then
      return true
    end
  end
  return speak_spd(text, lang)
end

-- ---------------------------------------------------------------------------
-- Selections
-- ---------------------------------------------------------------------------

-- Read the current visual selection by yanking it into register z (then
-- restoring z). Yank-based extraction is exact for multibyte text, unlike
-- slicing with `'<`/`'>` byte columns (whose end column is the START byte of
-- the last char, which truncates a multi-byte selection's final character).
local function get_visual_selection()
  local saved_content = vim.fn.getreg("z")
  local saved_type = vim.fn.getregtype("z")
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg("z")
  vim.fn.setreg("z", saved_content, saved_type)
  return text
end

-- Speak the visual selection (triggered by <Leader>tp in visual mode).
function M.speak_selection()
  local text = get_visual_selection()
  if text == "" then
    vim.notify("TTS: No selection", vim.log.levels.WARN)
    return
  end
  M.speak(text)
end

-- Speak the word under the cursor (command fallback).
function M.speak_current_word()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("TTS: No word under cursor", vim.log.levels.WARN)
    return
  end
  M.speak(word)
end

-- Command handler: selection if present, otherwise the word under the cursor.
function M.speak_selection_or_word()
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    M.speak_selection()
    return
  end
  -- normal mode: re-select the last visual selection (gv) and speak it
  vim.cmd("normal! gv")
  local m = vim.fn.mode()
  if m == "v" or m == "V" or m == "\22" then
    local text = get_visual_selection()
    if text ~= "" then
      M.speak(text)
      return
    end
  end
  M.speak_current_word()
end

-- ---------------------------------------------------------------------------
-- Setup
-- ---------------------------------------------------------------------------

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Right-click keeps its default popup menu; trigger speech with a key instead.
  vim.keymap.set("v", "<Leader>tp", M.speak_selection, {
    noremap = true,
    silent = true,
    desc = "TTS: Speak visual selection",
  })
  vim.keymap.set("n", "<Leader>tp", M.speak_selection_or_word, {
    noremap = true,
    silent = true,
    desc = "TTS: Speak last selection (or word under cursor)",
  })

  vim.api.nvim_create_user_command("TtsSpeak", function()
    M.speak_selection_or_word()
  end, { desc = "TTS: Speak selection (or word under cursor)" })

  vim.api.nvim_create_user_command("TtsDownloadVoice", function(a)
    M.download_voice(a.args, function(voice)
      vim.schedule(function()
        vim.notify("TTS: voice '" .. voice .. "' ready (downloaded to " .. M.config.piper.voice_dir .. ")", vim.log.levels.INFO)
      end)
    end)
  end, { desc = "TTS: Download piper voice (e.g. de_DE-thorsten-medium)", nargs = "?" })

  vim.api.nvim_create_user_command("TtsVoice", function(a)
    if a.args == "" then
      vim.notify("TTS: default voice = " .. M.config.piper.default_voice, vim.log.levels.INFO)
      return
    end
    M.set_voice(a.args)
    vim.notify("TTS: default voice set to " .. a.args, vim.log.levels.INFO)
  end, { desc = "TTS: Select piper voice (e.g. en_GB-alan-medium)", nargs = "?" })

  vim.api.nvim_create_user_command("TtsEngine", function(a)
    if a.args ~= "" then
      local valid = { auto = true, piper = true, edge = true, ["spd-say"] = true }
      if not valid[a.args] then
        vim.notify("TTS: engine must be 'auto', 'piper', 'edge' or 'spd-say'", vim.log.levels.ERROR)
        return
      end
      M.config.engine = a.args
    end
    vim.notify("TTS: engine = " .. M.config.engine, vim.log.levels.INFO)
  end, { desc = "TTS: Show/switch engine (auto|piper|edge|spd-say)", nargs = "?" })

  if vim.fn.executable("piper") ~= 1 and vim.fn.executable(M.config.piper.bin) == 0 then
    vim.notify(
      "TTS: piper binary not found. Install with: python3 -m venv ~/.local/share/piper-venv && ~/.local/share/piper-venv/bin/pip install piper-tts",
      vim.log.levels.WARN
    )
  end
end

return M
