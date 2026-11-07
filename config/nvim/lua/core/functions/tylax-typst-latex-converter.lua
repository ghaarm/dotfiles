-- Tylax: LaTeX → Typst aus Oil
-- https://github.com/scipenai/tylax
--
-- <leader>lt: TeX-Datei unter dem Cursor konvertieren
--
-- Funktionen:
--   - Konvertierung im aktuellen Oil-Verzeichnis
--   - Originaldatei bleibt erhalten
--   - Vorhandene Typst-Dateien werden nicht überschrieben
--   - Automatische Korrektur ungültiger Typst-Labels
--   - Automatische Korrektur von #v(20 mm) → #v(20mm)
--   - Einfügen in die eigene Typst-Vorlage
--   - Titel, Footer und Literaturverzeichnis bleiben erhalten
--   - Oil wird nach der Konvertierung aktualisiert

local M = {}

local template_path =
  vim.fs.joinpath(vim.fn.stdpath("config"), "templates", "typst-templates", "footer-footnotes-bibliography-tylax.typ")

-- ---------------------------------------------------------
-- 1. Typst-Nachbearbeitung
-- ---------------------------------------------------------

local function postprocess_typst(content)
  local count_labels = 0
  local count_lengths = 0

  -- Ungültige Labels und Referenzen korrigieren
  local updated = content:gsub("<([^<>\r\n]+)>", function(label)
    if not label:find("[,%s]") then
      return "<" .. label .. ">"
    end

    -- Nur typische Label-Bezeichner berücksichtigen
    if not label:match("^[%a][%w_%-]*") then
      return "<" .. label .. ">"
    end

    local fixed = label:gsub("[,%s]+", "-"):gsub("%-+", "-"):gsub("%-$", "")

    if fixed ~= label then
      count_labels = count_labels + 1
    end

    return "<" .. fixed .. ">"
  end)

  -- Fehlerhafte Längenangaben in #v() korrigieren
  -- Beispiel: #v(20 mm) → #v(20mm)
  local valid_units = {
    mm = true,
    cm = true,
    pt = true,
    em = true,
    ["in"] = true,
  }

  updated = updated:gsub("#v%(%s*(%d+%.?%d*)%s+(%a+)%s*%)", function(value, unit)
    if valid_units[unit] then
      count_lengths = count_lengths + 1
      return "#v(" .. value .. unit .. ")"
    end

    return "#v(" .. value .. " " .. unit .. ")"
  end)

  return updated, count_labels, count_lengths
end

-- ---------------------------------------------------------
-- 2. Typst-Vorlage einlesen und Inhalt einsetzen
-- ---------------------------------------------------------
-- Titel aus LaTeX oder Dateinamen ermitteln
local function get_title(input, basename)
  local file = io.open(input, "rb")

  if file then
    local tex = file:read("*a") or ""
    file:close()

    -- Einfache LaTeX-Titel übernehmen
    local title = tex:match("\\title%s*%{([^{}]+)%}")

    if title and not title:find("\\", 1, true) then
      return vim.trim(title)
    end
  end

  -- Fallback: Titel aus Dateinamen erzeugen
  local title = basename:gsub("%-ext$", ""):gsub("^gmics%-", "G'MICS "):gsub("[-_]", " ")

  title = title:gsub("^G'MICS (%l)", function(c)
    return "G'MICS " .. c:upper()
  end)

  return title
end

-- Text für Typst-Zeichenketten maskieren
local function escape_typst_string(value)
  return value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("[\r\n]+", " ")
end

local function merge_template(converted, input, basename)
  local file, err = io.open(template_path, "rb")

  if not file then
    return nil, "Typst-Vorlage nicht gefunden:\n" .. tostring(err)
  end

  local template = file:read("*a")
  file:close()

  -- Titel und Footer automatisch festlegen
  local title = get_title(input, basename)
  local footer = title

  template = template:gsub("{{INPUT:TITLE}}", function()
    return escape_typst_string(title)
  end)

  template = template:gsub("{{INPUT:FOOTER}}", function()
    return escape_typst_string(footer)
  end)

  -- Einfügemarke für den konvertierten Text
  local marker = "// TYLAX:CONTENT"
  local start_pos, end_pos = template:find(marker, 1, true)

  if not start_pos then
    return nil, "Einfügemarke fehlt: " .. marker
  end

  local merged = template:sub(1, start_pos - 1) .. converted .. "\n\n" .. template:sub(end_pos + 1)

  return merged
end

-- ---------------------------------------------------------
-- 3. LaTeX → Typst aus Oil
-- ---------------------------------------------------------

function M.latex_to_typst()
  local oil = require("oil")

  local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()

  if not entry or not dir or entry.type ~= "file" then
    vim.notify("Bitte eine TeX-Datei in Oil auswählen.", vim.log.levels.WARN)
    return
  end

  local basename = entry.name:match("^(.*)%.tex$")

  if not basename then
    vim.notify("Die ausgewählte Datei ist keine .tex-Datei.", vim.log.levels.WARN)
    return
  end

  local input = vim.fs.joinpath(dir, entry.name)
  local output = vim.fs.joinpath(dir, basename .. ".typ")

  -- Vorhandene Datei nicht überschreiben
  if vim.uv.fs_stat(output) then
    vim.notify("Datei existiert bereits: " .. output, vim.log.levels.WARN)
    return
  end

  -- CLI überprüfen
  if vim.fn.executable("t2l") ~= 1 then
    vim.notify("Tylax (t2l) ist nicht installiert oder nicht im PATH.", vim.log.levels.ERROR)
    return
  end

  -- Typst-Vorlage überprüfen
  if not vim.uv.fs_stat(template_path) then
    vim.notify("Typst-Vorlage nicht gefunden:\n" .. template_path, vim.log.levels.ERROR)
    return
  end

  -- Oil-Fenster und Buffer merken
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  -- -------------------------------------------------------
  -- 4. Tylax asynchron ausführen
  -- -------------------------------------------------------

  vim.system({
    "t2l",
    input,
    "--direction",
    "l2t",
    "--full-document",
    "--no-preamble",
    "--pretty",
    "--embed-warnings",
  }, {
    cwd = dir,
    text = true,
  }, function(result)
    vim.schedule(function()
      -- Konvertierungsfehler behandeln
      if result.code ~= 0 then
        vim.notify("Tylax-Konvertierung fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      local converted = result.stdout or ""

      if converted == "" then
        vim.notify("Tylax hat keinen Inhalt erzeugt.", vim.log.levels.ERROR)
        return
      end

      -- ---------------------------------------------------
      -- 5. Automatische Nachbearbeitung
      -- ---------------------------------------------------

      local corrected_content, count_labels, count_lengths = postprocess_typst(converted)

      -- ---------------------------------------------------
      -- 6. Inhalt in Typst-Vorlage einsetzen
      -- ---------------------------------------------------

      local merged, err = merge_template(corrected_content, input, basename)

      if not merged then
        vim.notify(err, vim.log.levels.ERROR)
        return
      end

      -- Erneut prüfen, ob Zieldatei schon existiert
      if vim.uv.fs_stat(output) then
        vim.notify("Datei existiert bereits: " .. output, vim.log.levels.WARN)
        return
      end

      -- Exklusiv erstellen: keine vorhandene Datei überschreiben
      local fd, open_err = vim.uv.fs_open(output, "wx", 420)

      if not fd then
        vim.notify("Datei konnte nicht erstellt werden:\n" .. tostring(open_err), vim.log.levels.ERROR)
        return
      end

      local written, write_err = vim.uv.fs_write(fd, merged, 0)
      vim.uv.fs_close(fd)

      if not written or written ~= #merged then
        vim.notify(
          "Fehler beim Schreiben der Typst-Datei:\n" .. tostring(write_err or "Unvollständiger Schreibvorgang"),
          vim.log.levels.ERROR
        )
        return
      end

      vim.notify(
        string.format(
          "Erstellt: %s.typ\n%d Labelkorrekturen\n%d Längenkorrekturen",
          basename,
          count_labels,
          count_lengths
        ),
        vim.log.levels.INFO
      )

      -- ---------------------------------------------------
      -- 7. Oil aktualisieren
      -- ---------------------------------------------------

      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_call(win, function()
          require("oil.actions").refresh.callback()
        end)
      end
    end)
  end)
end

-- ---------------------------------------------------------
-- 8. Keymap ausschließlich in Oil aktivieren
-- ---------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",

  callback = function(args)
    vim.keymap.set("n", "<leader>lt", M.latex_to_typst, {
      buffer = args.buf,
      desc = "Tylax: LaTeX → Typst",
    })
  end,
})

return M
