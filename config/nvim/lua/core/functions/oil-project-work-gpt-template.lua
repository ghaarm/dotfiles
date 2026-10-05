-- ~/.config/nvim/lua/core/functions/oil-project-template.lua
--
-- Erstellt im aktuellen Oil-Verzeichnis:
--
-- projektname/
-- ├── PROJECT.md
-- ├── DECISIONS.md
-- ├── manuscript/
-- └── research/
--     ├── EVIDENCE.md
--     └── sources/
--
-- <leader>cp = neues Projekt erstellen

local M = {}

local template_dir = vim.fs.joinpath(vim.fn.expand("~"), ".config", "nvim", "templates", "project-work-gpt")

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
-- Template lesen und Platzhalter ersetzen
-- ---------------------------------------------------------

local function render_template(template_name, project_name)
  local template_path = vim.fs.joinpath(template_dir, template_name)

  local file, err = io.open(template_path, "rb")

  if not file then
    return nil, "Template konnte nicht gelesen werden:\n" .. template_path .. "\n" .. tostring(err)
  end

  local content = file:read("*a")
  file:close()

  content = content:gsub("{{PROJECT_NAME}}", function()
    return project_name
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
-- Projekt erstellen
-- ---------------------------------------------------------

local function create_project(project_name)
  local current_dir = get_oil_dir()

  if not current_dir then
    return
  end

  project_name = vim.trim(project_name or "")

  if project_name == "" then
    return
  end

  -- Verhindert, dass versehentlich ein Pfad
  -- statt eines Projektnamens eingegeben wird.
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

  -- -------------------------------------------------------
  -- Templates zuerst prüfen
  -- -------------------------------------------------------

  local project_content, project_err = render_template("PROJECT.md", project_name)

  if not project_content then
    vim.notify(project_err, vim.log.levels.ERROR)
    return
  end

  local decisions_content, decisions_err = render_template("DECISIONS.md", project_name)

  if not decisions_content then
    vim.notify(decisions_err, vim.log.levels.ERROR)
    return
  end

  local evidence_content, evidence_err = render_template("EVIDENCE.md", project_name)

  if not evidence_content then
    vim.notify(evidence_err, vim.log.levels.ERROR)
    return
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
    local ok = vim.fn.mkdir(dir, "p")

    if ok == 0 then
      vim.notify("Verzeichnis konnte nicht erstellt werden:\n" .. dir, vim.log.levels.ERROR)
      return
    end
  end

  -- -------------------------------------------------------
  -- Dateien erstellen
  -- -------------------------------------------------------

  local files = {
    {
      path = vim.fs.joinpath(project_dir, "PROJECT.md"),
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

  require("oil.actions").refresh.callback()
end

-- ---------------------------------------------------------
-- Öffentliche Funktion
-- ---------------------------------------------------------

function M.new_project()
  vim.ui.input({
    prompt = "Projektname: ",
  }, function(project_name)
    if not project_name then
      return
    end

    create_project(project_name)
  end)
end

-- ---------------------------------------------------------
-- Command
-- ---------------------------------------------------------

vim.api.nvim_create_user_command("OilNewProject", function()
  M.new_project()
end, {
  desc = "Neue Projektstruktur im aktuellen Oil-Verzeichnis",
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
      desc = "Oil: New project",
    })
  end,
})

return M
