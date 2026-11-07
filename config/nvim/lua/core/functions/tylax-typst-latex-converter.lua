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
local processing = require("core.functions.tylax-processing")

local template_path =
  vim.fs.joinpath(vim.fn.stdpath("config"), "templates", "typst-templates", "footer-footnotes-bibliography-tylax.typ")

-- ---------------------------------------------------------
-- Typst-Vorlage einlesen und Inhalt einsetzen
-- ---------------------------------------------------------
-- Titel aus LaTeX oder Dateinamen ermitteln
local function get_title(basename)
  return basename:gsub("[-_]", " ")
end

-- Text für Typst-Zeichenketten maskieren
local function escape_typst_string(value)
  return value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("[\r\n]+", " ")
end

local function merge_template(converted, basename, options)
  local file, err = io.open(template_path, "rb")

  if not file then
    return nil, "Typst-Vorlage nicht gefunden:\n" .. tostring(err)
  end

  local template = file:read("*a")
  file:close()

  -- Titel und Footer automatisch festlegen
  local title = options.title or get_title(basename)
  local footer = title

  template = template:gsub("{{INPUT:TITLE}}", function()
    return escape_typst_string(title)
  end)

  template = template:gsub("{{INPUT:FOOTER}}", function()
    return escape_typst_string(footer)
  end)
  template = template:gsub("{{INPUT:TOC%-LINK}}", function()
    return options.toc and 'link(<inhaltsverzeichnis>)[Zurück zum Inhaltsverzeichnis]' or ''
  end)

  local toc = options.toc and '#outline(title: "Inhaltsverzeichnis") <inhaltsverzeichnis>' or ''
  local lot = options.lot and '#outline(target: figure.where(kind: table), title: "Tabellenverzeichnis")' or ''
  local lof = options.lof and '#outline(target: figure.where(kind: image), title: "Abbildungsverzeichnis")' or ''
  template = template:gsub("// TYLAX:TOC", function() return toc end)
  template = template:gsub("// TYLAX:LOT", function() return lot end)
  template = template:gsub("// TYLAX:LOF", function() return lof end)
  if not options.maketitle then
    template = template:gsub("// TYLAX:TITLE:START.-// TYLAX:TITLE:END", "")
  else
    template = template:gsub("// TYLAX:TITLE:START", "")
    template = template:gsub("// TYLAX:TITLE:END", "")
  end

  -- Einfügemarke für den konvertierten Text
  local marker = "// TYLAX:CONTENT"
  local start_pos, end_pos = template:find(marker, 1, true)

  if not start_pos then
    return nil, "Einfügemarke fehlt: " .. marker
  end

  local merged = template:sub(1, start_pos - 1) .. converted .. "\n\n" .. template:sub(end_pos + 1)
  local bibliography = template:match('#bibliography%s*%(%s*"([^"]+)"')
  local warnings
  merged, warnings = processing.resolve_bibliography(merged, bibliography)
  return merged, nil, warnings
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
  local t2l = vim.fn.executable("t2l") == 1 and "t2l" or vim.fn.expand("~/.cargo/bin/t2l")
  if vim.fn.executable(t2l) ~= 1 then
    vim.notify("Tylax (t2l) ist nicht installiert oder nicht im PATH.", vim.log.levels.ERROR)
    return
  end

  local source_file, source_err = io.open(input, "rb")
  if not source_file then
    vim.notify("LaTeX-Datei kann nicht gelesen werden: " .. tostring(source_err), vim.log.levels.ERROR)
    return
  end
  local source = source_file:read("*a")
  source_file:close()
  local prepared, options = processing.prepare(source)
  if not prepared then
    vim.notify("LaTeX-Dokument: " .. options, vim.log.levels.ERROR)
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
    t2l,
    "--direction",
    "l2t",
    "--full-document",
    "--no-preamble",
    "--pretty",
    "--embed-warnings",
  }, {
    cwd = dir,
    text = true,
    stdin = prepared,
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

      local corrected_content, counts = processing.postprocess(converted)

      -- ---------------------------------------------------
      -- 6. Inhalt in Typst-Vorlage einsetzen
      -- ---------------------------------------------------

      local merged, err, bibliography_warnings = merge_template(corrected_content, basename, options)

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
          counts.labels,
          counts.lengths
        ),
        vim.log.levels.INFO
      )
      if result.stderr and result.stderr ~= "" then
        vim.notify("Tylax-Warnungen:\n" .. result.stderr, vim.log.levels.WARN)
      end
      for _, warning in ipairs(options.warnings) do
        vim.notify("Tylax: " .. warning, vim.log.levels.WARN)
      end
      for _, warning in ipairs(bibliography_warnings) do
        vim.notify("Tylax: " .. warning, vim.log.levels.WARN)
      end

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
