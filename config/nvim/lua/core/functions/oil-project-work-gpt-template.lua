-- ~/.config/nvim/lua/core/functions/oil-project-work-gpt-template.lua
--
-- Erstellt im aktuellen Oil-Verzeichnis ein neues Work-GPT-Projekt:
--
-- projektname/
-- ├── PROJECT.md
-- ├── DECISIONS.md
-- ├── manuscript/
-- │   └── bilder-latex -> .../gmics-latex/bilder-latex
-- │       [nur bei Projektarten mit bilder_latex = true]
-- └── research/
--     ├── EVIDENCE.md
--     ├── notizen.md
--     ├── openevidence.md
--     └── sources/
--
-- Projekt erstellen:
--   <leader>cw
--   :OilNewProject
--
-- Die allgemeinen Template-Marker
--
--   {{INPUT}}
--   {{INPUT:NAME}}
--   {{MIRROR:NAME}}
--
-- werden nicht in dieser Datei verarbeitet, sondern durch:
--
--   lua/core/functions/fill-template.lua
--
-- Nach dem Erstellen eines Projekts wird PROJECT.md geöffnet und der
-- Template-Filler automatisch gestartet.
--
-- {{PROJECT-NAME}} ist projektspezifisch und wird bereits beim Erstellen
-- des Projekts durch den Verzeichnis-/Projektnamen ersetzt.

local M = {}

-- ---------------------------------------------------------
-- Pfade
-- ---------------------------------------------------------

local template_dir = vim.fs.joinpath(vim.fn.expand("~"), ".config", "nvim", "templates", "project-work-gpt")

local bilder_latex_source =
  "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/R Statistik, icloud/Latex, icloud/Latex Projekte/icu-latex/gmics-latex/bilder-latex"

-- ---------------------------------------------------------
-- Aktuelles Oil-Verzeichnis
-- ---------------------------------------------------------

local function get_oil_dir()
  local oil = require("oil")
  local dir = oil.get_current_dir()

  if not dir then
    vim.notify("Aktuelles Oil-Verzeichnis konnte nicht ermittelt werden", vim.log.levels.ERROR)
    return nil
  end

  return dir
end

-- ---------------------------------------------------------
-- Template lesen
-- ---------------------------------------------------------

local function read_template(template_name)
  local template_path = vim.fs.joinpath(template_dir, template_name)

  local file, err = io.open(template_path, "rb")

  if not file then
    return nil, "Template konnte nicht gelesen werden:\n" .. template_path .. "\n" .. tostring(err)
  end

  local content = file:read("*a")
  file:close()

  return content
end

-- ---------------------------------------------------------
-- Projektname einsetzen
-- ---------------------------------------------------------

local function render_project_name(content, project_name)
  return content:gsub("{{PROJECT%-NAME}}", function()
    return project_name
  end)
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
-- Projekt erstellen
-- ---------------------------------------------------------

local function create_project(project_name, project_template, create_bilder_latex)
  local current_dir = get_oil_dir()

  if not current_dir then
    return
  end

  project_name = vim.trim(project_name or "")

  if project_name == "" then
    return
  end

  if project_name:find("/", 1, true) then
    vim.notify("Der Projektname darf keinen / enthalten.", vim.log.levels.ERROR)
    return
  end

  local project_dir = vim.fs.joinpath(current_dir, project_name)

  -- -------------------------------------------------------
  -- Bestehende Projekte niemals überschreiben
  -- -------------------------------------------------------

  if vim.uv.fs_stat(project_dir) then
    vim.notify("Verzeichnis existiert bereits:\n" .. project_dir, vim.log.levels.WARN)
    return
  end

  -- -------------------------------------------------------
  -- Templates zuerst lesen
  -- -------------------------------------------------------

  local project_content, project_err = read_template(project_template)

  if not project_content then
    vim.notify(project_err, vim.log.levels.ERROR)
    return
  end

  local decisions_content, decisions_err = read_template("DECISIONS.md")

  if not decisions_content then
    vim.notify(decisions_err, vim.log.levels.ERROR)
    return
  end

  local evidence_content, evidence_err = read_template("EVIDENCE.md")

  if not evidence_content then
    vim.notify(evidence_err, vim.log.levels.ERROR)
    return
  end

  -- -------------------------------------------------------
  -- PROJECT-NAME sofort ersetzen
  --
  -- INPUT und MIRROR bleiben persistent in den Dateien und
  -- werden anschließend vom allgemeinen Template-Filler
  -- verarbeitet.
  -- -------------------------------------------------------

  project_content = render_project_name(project_content, project_name)

  decisions_content = render_project_name(decisions_content, project_name)

  evidence_content = render_project_name(evidence_content, project_name)

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
    local ok = vim.fn.mkdir(dir, "p")

    if ok == 0 then
      vim.notify("Verzeichnis konnte nicht erstellt werden:\n" .. dir, vim.log.levels.ERROR)
      return
    end
  end

  -- -------------------------------------------------------
  -- bilder-latex-Symlink
  --
  -- Wird nur für Projektarten angelegt, bei denen
  -- bilder_latex = true gesetzt ist.
  -- -------------------------------------------------------

  if create_bilder_latex then
    if vim.fn.isdirectory(bilder_latex_source) ~= 1 then
      vim.notify("Zentrales bilder-latex-Verzeichnis nicht gefunden:\n" .. bilder_latex_source, vim.log.levels.ERROR)
      return
    end

    local bilder_latex_link = vim.fs.joinpath(project_dir, "manuscript", "bilder-latex")

    local ok, err = vim.uv.fs_symlink(bilder_latex_source, bilder_latex_link)

    if not ok then
      vim.notify("Symlink bilder-latex konnte nicht erstellt werden:\n" .. tostring(err), vim.log.levels.ERROR)
      return
    end
  end

  -- -------------------------------------------------------
  -- Dateien erstellen
  -- -------------------------------------------------------

  local project_file = vim.fs.joinpath(project_dir, "PROJECT.md")

  local files = {
    {
      path = project_file,
      content = project_content,
    },

    {
      path = vim.fs.joinpath(project_dir, "DECISIONS.md"),
      content = decisions_content,
    },

    {
      path = vim.fs.joinpath(project_dir, "research", "EVIDENCE.md"),
      content = evidence_content,
    },

    {
      path = vim.fs.joinpath(project_dir, "research", "notizen.md"),
      content = "# Notizen\n\n",
    },

    {
      path = vim.fs.joinpath(project_dir, "research", "openevidence.md"),
      content = "# OpenEvidence\n\n",
    },
  }

  for _, item in ipairs(files) do
    local ok, err = write_file(item.path, item.content)

    if not ok then
      vim.notify("Datei konnte nicht erstellt werden:\n" .. item.path .. "\n" .. tostring(err), vim.log.levels.ERROR)
      return
    end
  end

  -- -------------------------------------------------------
  -- Fertig
  -- -------------------------------------------------------

  vim.notify("Projekt erstellt:\n" .. project_name, vim.log.levels.INFO)

  -- PROJECT.md öffnen
  vim.cmd.edit(vim.fn.fnameescape(project_file))

  -- Allgemeinen Template-Filler direkt aktivieren
  require("core.functions.fill-template").fill()
end

-- ---------------------------------------------------------
-- Neues Projekt
-- ---------------------------------------------------------

function M.new_project()
  local project_types = {
    {
      label = "PROJECT-allgemein.md",
      template = "PROJECT-ALLGEMEIN.md",
      bilder_latex = false,
    },

    {
      label = "PROJECT-G'MICS.md",
      template = "PROJECT-GMICS.md",
      bilder_latex = true,
    },

    {
      label = "PROJECT-LATEX.md",
      template = "PROJECT-LATEX.md",
      bilder_latex = true,
    },
  }

  vim.ui.select(project_types, {
    prompt = "Projektart: ",

    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end

    vim.ui.input({
      prompt = "Projektname: ",
    }, function(project_name)
      if not project_name then
        return
      end

      create_project(project_name, choice.template, choice.bilder_latex)
    end)
  end)
end

-- ---------------------------------------------------------
-- Command
-- ---------------------------------------------------------

vim.api.nvim_create_user_command("OilNewProject", function()
  M.new_project()
end, {
  desc = "Neues Work-Projekt erstellen",
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
      desc = "Oil: New Work project",
    })
  end,
})

return M
