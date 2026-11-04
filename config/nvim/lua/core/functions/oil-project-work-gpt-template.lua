-- ~/.config/nvim/lua/core/functions/oil-project-work-template.lua
--
-- Erstellt im aktuellen Oil-Verzeichnis ein neues Work-Projekt für
-- Claude oder GPT Work. Ersetzt oil-project-work-gpt-template.lua.
--
-- Arbeitsbereich-Erkennung (vom Oil-Verzeichnis aufwärts bis ~):
--
--   Claude-Root:  enthält CLAUDE.md UND den Ordner .claude/
--                 (Projekt-CLAUDE.md-Dateien haben kein .claude/ daneben
--                 und werden deshalb nicht als Root erkannt)
--   GPT-Root:     enthält AGENTS.md
--
--   Der nächstgelegene Treffer gewinnt. Wird kein Arbeitsbereich erkannt,
--   wird nachgefragt.
--
-- Projektstruktur:
--
-- projektname/
-- ├── CLAUDE.md                [nur Claude: bindet PROJECT.md und DECISIONS.md ein]
-- ├── PROJECT.md
-- ├── DECISIONS.md
-- ├── manuscript/
-- │   ├── <hauptdatei>.tex oder <hauptdatei>.typ
-- │   │   [optional neu erstellt]
-- │   └── bilder-latex -> .../gmics-latex/bilder-latex
-- │       [nur bei Projektarten mit bilder_latex = true]
-- └── research/
--     ├── EVIDENCE.md
--     ├── search-log.md        [nur Claude]
--     ├── notizen.md
--     ├── openevidence.md
--     └── sources/
--
-- Projekt erstellen:
--   <leader>cw          (in Oil)
--   :OilNewProject      (automatische Erkennung)
--   :OilNewProject claude
--   :OilNewProject gpt
--
-- Hauptdatei, Template-Marker und fill-template.lua wie bisher:
--   {{PROJECT-NAME}} wird hier ersetzt, {{INPUT:MAINFILE}}/{{MIRROR:MAINFILE}}
--   je nach Auswahl, alle übrigen Marker durch
--   lua/core/functions/fill-template.lua.

local M = {}

-- ---------------------------------------------------------
-- Konfiguration
-- ---------------------------------------------------------

local templates_root = vim.fs.joinpath(vim.fn.expand("~"), ".config", "nvim", "templates")

local bilder_latex_source =
  "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/R Statistik, icloud/Latex, icloud/Latex Projekte/icu-latex/gmics-latex/bilder-latex"

-- Nach dem Erstellen eines Claude-Projekts Claude Code in einem
-- kitty-Split im Projektordner starten.
-- Voraussetzung in kitty.conf: allow_remote_control yes
--                              listen_on unix:/tmp/kitty
local open_claude_in_kitty = false

local workspaces = {
  claude = {
    label = "Claude",
    template_dir = vim.fs.joinpath(templates_root, "project-work-claude"),
    -- Zusätzliche Dateien: Template (im template_dir) -> Ziel (relativ zum Projekt)
    extra_templates = {
      { template = "CLAUDE.md", target = "CLAUDE.md" },
    },
    search_log = true,
  },

  gpt = {
    label = "GPT Work",
    template_dir = vim.fs.joinpath(templates_root, "project-work-gpt"),
    extra_templates = {},
    search_log = false,
  },
}

-- ---------------------------------------------------------
-- Hilfsfunktionen Dateisystem
-- ---------------------------------------------------------

local function is_type(path, kind)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == kind
end

-- ---------------------------------------------------------
-- Arbeitsbereich erkennen
--
-- Gibt "claude", "gpt" oder nil sowie den Root-Pfad zurück.
-- ---------------------------------------------------------

local function detect_workspace(start_dir)
  local home = vim.fs.normalize(vim.fn.expand("~"))
  local dir = vim.fs.normalize(start_dir):gsub("/$", "")

  while dir and dir ~= "" do
    if dir == home then
      break
    end

    if is_type(vim.fs.joinpath(dir, "CLAUDE.md"), "file") and is_type(vim.fs.joinpath(dir, ".claude"), "directory") then
      return "claude", dir
    end

    if is_type(vim.fs.joinpath(dir, "AGENTS.md"), "file") then
      return "gpt", dir
    end

    local parent = vim.fs.dirname(dir)

    if parent == dir then
      break
    end

    dir = parent
  end

  return nil, nil
end

-- ---------------------------------------------------------
-- Aktuelles Oil-Verzeichnis
-- ---------------------------------------------------------

local function get_oil_dir()
  local ok, oil = pcall(require, "oil")
  local dir = ok and oil.get_current_dir() or nil

  if not dir then
    vim.notify("Aktuelles Oil-Verzeichnis konnte nicht ermittelt werden", vim.log.levels.ERROR)
    return nil
  end

  return dir
end

-- ---------------------------------------------------------
-- Template lesen
--
-- template_names: String oder Liste von Kandidaten; der erste
-- vorhandene wird verwendet (z. B. PROJECT-GMICS-LATEX.md im
-- GPT-Ordner, PROJECT-GMICS.md im Claude-Ordner).
-- ---------------------------------------------------------

local function read_template(ws, template_names)
  if type(template_names) == "string" then
    template_names = { template_names }
  end

  local tried = {}

  for _, name in ipairs(template_names) do
    local template_path = vim.fs.joinpath(ws.template_dir, name)
    local file = io.open(template_path, "rb")

    if file then
      local content = file:read("*a")
      file:close()
      return content
    end

    table.insert(tried, template_path)
  end

  return nil, "Template konnte nicht gelesen werden:\n" .. table.concat(tried, "\n")
end

-- ---------------------------------------------------------
-- Platzhalter ersetzen
-- ---------------------------------------------------------

local function render_project_name(content, project_name)
  return (content:gsub("{{PROJECT%-NAME}}", function()
    return project_name
  end))
end

local function render_mainfile(content, mainfile)
  content = content:gsub("{{INPUT:MAINFILE}}", function()
    return mainfile
  end)

  content = content:gsub("{{MIRROR:MAINFILE}}", function()
    return mainfile
  end)

  return content
end

-- ---------------------------------------------------------
-- Datei schreiben
-- ---------------------------------------------------------

local function write_file(path, content)
  local file, err = io.open(path, "wb")

  if not file then
    return false, err
  end

  file:write(content)
  file:close()

  return true
end

-- ---------------------------------------------------------
-- Hauptdateinamen normalisieren
-- ---------------------------------------------------------

local function normalize_mainfile(mainfile, extension)
  mainfile = vim.trim(mainfile or "")

  if mainfile == "" then
    return nil
  end

  mainfile = mainfile:gsub("%." .. extension .. "$", "")

  if mainfile == "" then
    return nil
  end

  return mainfile
end

-- ---------------------------------------------------------
-- Claude Code in kitty-Split öffnen (optional)
-- ---------------------------------------------------------

local function launch_claude(project_dir)
  if not open_claude_in_kitty then
    return
  end

  if vim.fn.executable("kitty") ~= 1 or not vim.env.KITTY_WINDOW_ID then
    vim.notify("kitty-Remote-Control nicht verfügbar; Claude nicht gestartet.", vim.log.levels.WARN)
    return
  end

  vim.system({
    "kitty",
    "@",
    "launch",
    "--type=window",
    "--location=vsplit",
    "--cwd=" .. project_dir,
    "claude",
    "/weiter",
  }, { text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify("Claude konnte nicht gestartet werden:\n" .. (res.stderr or ""), vim.log.levels.WARN)
      end)
    end
  end)
end

-- ---------------------------------------------------------
-- Projekt erstellen
--
-- mainfile_mode:
--   "new"      -> Hauptdatei eintragen und .tex oder .typ erstellen
--   "existing" -> Hauptdatei nur eintragen
--   "unset"    -> Template-Marker unverändert lassen
-- ---------------------------------------------------------

local function create_project(ws_key, current_dir, project_name, project_choice, mainfile_mode, mainfile)
  local ws = workspaces[ws_key]
  local extension = project_choice.extension

  project_name = vim.trim(project_name or "")

  if project_name == "" then
    return
  end

  if project_name:find("/", 1, true) then
    vim.notify("Der Projektname darf keinen / enthalten.", vim.log.levels.ERROR)
    return
  end

  local project_dir = vim.fs.joinpath(current_dir, project_name)

  -- Bestehende Projekte niemals überschreiben
  if vim.uv.fs_stat(project_dir) then
    vim.notify("Verzeichnis existiert bereits:\n" .. project_dir, vim.log.levels.WARN)
    return
  end

  -- Hauptdatei prüfen
  if mainfile_mode == "new" or mainfile_mode == "existing" then
    mainfile = normalize_mainfile(mainfile, extension)

    if not mainfile then
      vim.notify("Kein gültiger Name für die Hauptdatei angegeben.", vim.log.levels.ERROR)
      return
    end

    if mainfile:find("/", 1, true) or mainfile:find("\\", 1, true) then
      vim.notify("Der Name der Hauptdatei darf keinen Pfad enthalten.", vim.log.levels.ERROR)
      return
    end
  end

  -- -------------------------------------------------------
  -- Templates zuerst lesen (bevor irgendetwas angelegt wird)
  -- -------------------------------------------------------

  local project_content, err = read_template(ws, project_choice.template)
  if not project_content then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local decisions_content
  decisions_content, err = read_template(ws, "DECISIONS.md")
  if not decisions_content then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local evidence_content
  evidence_content, err = read_template(ws, "EVIDENCE.md")
  if not evidence_content then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local extra_files = {}

  for _, extra in ipairs(ws.extra_templates) do
    local content
    content, err = read_template(ws, extra.template)

    if not content then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    table.insert(extra_files, {
      path = vim.fs.joinpath(project_dir, extra.target),
      content = render_project_name(content, project_name),
    })
  end

  -- PROJECT-NAME sofort ersetzen
  project_content = render_project_name(project_content, project_name)
  decisions_content = render_project_name(decisions_content, project_name)
  evidence_content = render_project_name(evidence_content, project_name)

  -- Hauptdatei einsetzen (bei "unset" bleiben die Marker erhalten)
  if mainfile_mode == "new" or mainfile_mode == "existing" then
    project_content = render_mainfile(project_content, mainfile)
  end

  -- -------------------------------------------------------
  -- Verzeichnisse erstellen
  -- -------------------------------------------------------

  local directories = {
    project_dir,
    vim.fs.joinpath(project_dir, "manuscript"),
    vim.fs.joinpath(project_dir, "research"),
    vim.fs.joinpath(project_dir, "research", "sources"),
  }

  for _, dir in ipairs(directories) do
    if vim.fn.mkdir(dir, "p") == 0 then
      vim.notify("Verzeichnis konnte nicht erstellt werden:\n" .. dir, vim.log.levels.ERROR)
      return
    end
  end

  -- -------------------------------------------------------
  -- bilder-latex-Symlink
  -- -------------------------------------------------------

  if project_choice.bilder_latex then
    if vim.fn.isdirectory(bilder_latex_source) ~= 1 then
      vim.notify("Zentrales bilder-latex-Verzeichnis nicht gefunden:\n" .. bilder_latex_source, vim.log.levels.ERROR)
      return
    end

    local bilder_latex_link = vim.fs.joinpath(project_dir, "manuscript", "bilder-latex")
    local ok, link_err = vim.uv.fs_symlink(bilder_latex_source, bilder_latex_link)

    if not ok then
      vim.notify("Symlink bilder-latex konnte nicht erstellt werden:\n" .. tostring(link_err), vim.log.levels.ERROR)
      return
    end
  end

  -- -------------------------------------------------------
  -- Dateien vorbereiten
  -- -------------------------------------------------------

  local project_file = vim.fs.joinpath(project_dir, "PROJECT.md")

  local files = {
    { path = project_file, content = project_content },
    { path = vim.fs.joinpath(project_dir, "DECISIONS.md"), content = decisions_content },
    { path = vim.fs.joinpath(project_dir, "research", "EVIDENCE.md"), content = evidence_content },
    { path = vim.fs.joinpath(project_dir, "research", "notizen.md"), content = "# Notizen\n\n" },
    { path = vim.fs.joinpath(project_dir, "research", "openevidence.md"), content = "# OpenEvidence\n\n" },
  }

  if ws.search_log then
    table.insert(files, {
      path = vim.fs.joinpath(project_dir, "research", "search-log.md"),
      content = "# Suchprotokoll – " .. project_name .. "\n\n",
    })
  end

  vim.list_extend(files, extra_files)

  if mainfile_mode == "new" then
    table.insert(files, {
      path = vim.fs.joinpath(project_dir, "manuscript", mainfile .. "." .. extension),
      content = "",
    })
  end

  -- -------------------------------------------------------
  -- Dateien schreiben
  -- -------------------------------------------------------

  for _, item in ipairs(files) do
    local ok, write_err = write_file(item.path, item.content)

    if not ok then
      vim.notify(
        "Datei konnte nicht erstellt werden:\n" .. item.path .. "\n" .. tostring(write_err),
        vim.log.levels.ERROR
      )
      return
    end
  end

  -- -------------------------------------------------------
  -- Fertig
  -- -------------------------------------------------------

  vim.notify(ws.label .. "-Projekt erstellt:\n" .. project_name, vim.log.levels.INFO)

  vim.cmd.edit(vim.fn.fnameescape(project_file))

  require("core.functions.fill-template").fill()

  if ws_key == "claude" then
    launch_claude(project_dir)
  end
end

-- ---------------------------------------------------------
-- Projektarten
--
-- template: String oder Liste von Kandidaten (erster vorhandener gewinnt)
-- ---------------------------------------------------------

local project_types = {
  {
    label = "PROJECT-allgemein.md",
    template = "PROJECT-ALLGEMEIN.md",
    bilder_latex = false,
    extension = "tex",
  },
  {
    label = "PROJECT-G'MICS-LATEX.md",
    template = { "PROJECT-GMICS-LATEX.md", "PROJECT-GMICS.md" },
    bilder_latex = true,
    extension = "tex",
  },
  {
    label = "PROJECT-G'MICS-TYPST.md",
    template = "PROJECT-GMICS-TYPST.md",
    bilder_latex = true,
    extension = "typ",
  },
  {
    label = "PROJECT-LATEX.md",
    template = "PROJECT-LATEX.md",
    bilder_latex = true,
    extension = "tex",
  },
  {
    label = "Beamer-Vortrag (LaTeX)",
    template = "PROJECT-BEAMER-LATEX.md",
    bilder_latex = true,
    extension = "tex",
  },
  {
    label = "Typst-Dokument",
    template = "PROJECT-TYPST.md",
    bilder_latex = true,
    extension = "typ",
  },
  {
    label = "Touying-Vortrag (Typst)",
    template = "PROJECT-TOUYING-TYPST.md",
    bilder_latex = true,
    extension = "typ",
  },
  {
    label = "PROJECT-LEITUNGSTEAM.md",
    template = "PROJECT-LEITUNGSTEAM.md",
    bilder_latex = true,
    extension = "tex",
  },
}

local mainfile_choices = {
  { label = "Neue Hauptdatei erstellen", mode = "new" },
  { label = "Hauptdatei existiert bereits", mode = "existing" },
  { label = "Noch keine Hauptdatei festlegen", mode = "unset" },
}

-- ---------------------------------------------------------
-- Dialog: Projektart, Name, Hauptdatei
-- ---------------------------------------------------------

local function run_dialog(ws_key, current_dir)
  local ws = workspaces[ws_key]

  vim.ui.select(project_types, {
    prompt = "Projektart (" .. ws.label .. "): ",
    format_item = function(item)
      return item.label
    end,
  }, function(project_choice)
    if not project_choice then
      return
    end

    vim.ui.input({ prompt = "Projektname: " }, function(project_name)
      project_name = vim.trim(project_name or "")

      if project_name == "" then
        return
      end

      vim.ui.select(mainfile_choices, {
        prompt = "Hauptdatei: ",
        format_item = function(item)
          return item.label
        end,
      }, function(mainfile_choice)
        if not mainfile_choice then
          return
        end

        if mainfile_choice.mode == "unset" then
          create_project(ws_key, current_dir, project_name, project_choice, "unset", nil)
          return
        end

        vim.ui.input({ prompt = "Name der Hauptdatei: " }, function(mainfile)
          mainfile = normalize_mainfile(mainfile, project_choice.extension)

          if not mainfile then
            return
          end

          create_project(ws_key, current_dir, project_name, project_choice, mainfile_choice.mode, mainfile)
        end)
      end)
    end)
  end)
end

-- ---------------------------------------------------------
-- Neues Projekt
--
-- forced_ws: "claude", "gpt" oder nil (automatisch erkennen)
-- ---------------------------------------------------------

function M.new_project(forced_ws)
  local current_dir = get_oil_dir()

  if not current_dir then
    return
  end

  if forced_ws then
    if not workspaces[forced_ws] then
      vim.notify("Unbekannter Arbeitsbereich: " .. forced_ws .. " (claude|gpt)", vim.log.levels.ERROR)
      return
    end

    run_dialog(forced_ws, current_dir)
    return
  end

  local ws_key, root = detect_workspace(current_dir)

  if ws_key then
    vim.notify(workspaces[ws_key].label .. "-Arbeitsbereich erkannt:\n" .. root, vim.log.levels.INFO)
    run_dialog(ws_key, current_dir)
    return
  end

  -- Kein Arbeitsbereich erkannt -> nachfragen
  vim.ui.select({ "claude", "gpt" }, {
    prompt = "Kein Arbeitsbereich erkannt – für welchen? ",
    format_item = function(key)
      return workspaces[key].label
    end,
  }, function(choice)
    if choice then
      run_dialog(choice, current_dir)
    end
  end)
end

-- ---------------------------------------------------------
-- Command
-- ---------------------------------------------------------

vim.api.nvim_create_user_command("OilNewProject", function(opts)
  local arg = vim.trim(opts.args or "")
  M.new_project(arg ~= "" and arg or nil)
end, {
  nargs = "?",
  complete = function()
    return { "claude", "gpt" }
  end,
  desc = "Neues Work-Projekt erstellen (Claude oder GPT Work)",
})

-- ---------------------------------------------------------
-- Oil-Keymap
-- ---------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function(args)
    vim.keymap.set("n", "<leader>cw", function()
      M.new_project()
    end, {
      buffer = args.buf,
      desc = "Oil: New Work project (Claude/GPT)",
    })
  end,
})

return M
