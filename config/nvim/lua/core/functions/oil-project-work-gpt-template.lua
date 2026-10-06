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
-- Projekt erstellen:
--   <leader>cw
--   :OilNewProject
--
-- Offene PROJECT.md-Felder ausfüllen:
--   :ProjectFill
--
-- Persistente Template-Marker:
--
--   {{PROJECT-NAME}}
--       wird beim Erstellen automatisch ersetzt
--
--   {{INPUT}}
--       normale Eingabestelle
--
--   {{INPUT:NAME}}
--       benannte Eingabestelle
--
--   {{MIRROR:NAME}}
--       übernimmt den Inhalt von {{INPUT:NAME}}

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
-- PROJECT.md prüfen
-- ---------------------------------------------------------

local function is_project_file()
  return vim.fn.expand("%:t") == "PROJECT.md"
end

-- ---------------------------------------------------------
-- PROJECT.md-Formular aktivieren
-- ---------------------------------------------------------

function M.fill_project()
  if not is_project_file() then
    vim.notify("ProjectFill ist nur für PROJECT.md vorgesehen.", vim.log.levels.WARN)
    return
  end

  local ls = require("luasnip")

  local s = ls.snippet
  local i = ls.insert_node
  local f = ls.function_node
  local t = ls.text_node

  local bufnr = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local content = table.concat(lines, "\n")

  -- Gibt es überhaupt noch offene Eingaben?
  if not content:find("{{INPUT", 1, true) then
    vim.notify("Keine offenen PROJECT.md-Eingabefelder.", vim.log.levels.INFO)
    return
  end

  local nodes = {}

  local input_number = 1

  -- Name -> LuaSnip-Node-Nummer
  local named_inputs = {}

  local position = 1

  while true do
    local start_pos, end_pos, marker = content:find("({{.-}})", position)

    if not start_pos then
      local remaining = content:sub(position)

      if remaining ~= "" then
        table.insert(
          nodes,
          t(vim.split(remaining, "\n", {
            plain = true,
          }))
        )
      end

      break
    end

    -- -----------------------------------------------------
    -- Text vor dem Marker
    -- -----------------------------------------------------

    local before = content:sub(position, start_pos - 1)

    if before ~= "" then
      table.insert(
        nodes,
        t(vim.split(before, "\n", {
          plain = true,
        }))
      )
    end

    -- -----------------------------------------------------
    -- {{INPUT}}
    -- -----------------------------------------------------

    if marker == "{{INPUT}}" then
      table.insert(nodes, i(input_number, "{{INPUT}}"))

      input_number = input_number + 1
    else
      -- ---------------------------------------------------
      -- {{INPUT:NAME}}
      -- ---------------------------------------------------

      local input_name = marker:match("^{{INPUT:([^}]+)}}$")

      if input_name then
        local node_number = input_number

        named_inputs[input_name] = node_number

        table.insert(nodes, i(node_number, marker))

        input_number = input_number + 1
      else
        -- -------------------------------------------------
        -- {{MIRROR:NAME}}
        -- -------------------------------------------------

        local mirror_name = marker:match("^{{MIRROR:([^}]+)}}$")

        if mirror_name then
          local source_node = named_inputs[mirror_name]

          if source_node then
            table.insert(
              nodes,
              f(function(args)
                local value = args[1][1] or ""

                -- Solange das Feld noch nicht ausgefüllt
                -- wurde, bleibt der Mirror persistent.
                if value == "" or value:match("^{{INPUT:") then
                  return "{{MIRROR:" .. mirror_name .. "}}"
                end

                return value
              end, {
                source_node,
              })
            )
          else
            -- Der zugehörige INPUT wurde bereits in einer
            -- früheren Sitzung ausgefüllt oder befindet sich
            -- nicht mehr in der Datei.
            --
            -- In diesem Fall bleibt der Mirror unverändert.
            table.insert(nodes, t(marker))
          end
        else
          -- Unbekannte {{...}}-Marker unverändert lassen
          table.insert(nodes, t(marker))
        end
      end
    end

    position = end_pos + 1
  end

  -- -------------------------------------------------------
  -- Finaler Exit-Node
  -- -------------------------------------------------------

  table.insert(nodes, i(0))

  -- -------------------------------------------------------
  -- Buffer durch Snippet ersetzen
  -- -------------------------------------------------------

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    "",
  })

  vim.api.nvim_win_set_cursor(0, {
    1,
    0,
  })

  ls.snip_expand(s({
    trig = "",
    name = "PROJECT.md Formular",
  }, nodes))
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

  local project_content, project_err = read_template("PROJECT.md")

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
  -- Nur PROJECT-NAME sofort ersetzen
  --
  -- INPUT und MIRROR bleiben persistent in den Dateien.
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

  -- Formular direkt aktivieren
  M.fill_project()
end

-- ---------------------------------------------------------
-- Neues Projekt
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
-- Commands
-- ---------------------------------------------------------

vim.api.nvim_create_user_command("OilNewProject", function()
  M.new_project()
end, {
  desc = "Neues Work-Projekt erstellen",
})

vim.api.nvim_create_user_command("ProjectFill", function()
  M.fill_project()
end, {
  desc = "Offene PROJECT.md-Felder ausfüllen",
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

-- ---------------------------------------------------------
-- PROJECT.md-Keymap
-- ---------------------------------------------------------

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "PROJECT.md",

  callback = function(args)
    vim.keymap.set("n", "<localleader>cq", function()
      M.fill_project()
    end, {
      buffer = args.buf,
      desc = "Project: Fill open fields",
    })
  end,
})

return M
