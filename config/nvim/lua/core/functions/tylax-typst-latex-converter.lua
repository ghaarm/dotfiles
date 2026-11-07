-- Tylax: LaTeX → Typst aus Oil
-- https://github.com/scipenai/tylax
--
-- <leader>lt: TeX-Datei unter dem Cursor konvertieren
--
-- Funktionen:
--   - Konvertierung im aktuellen Oil-Verzeichnis
--   - Originaldatei bleibt erhalten
--   - Vorhandene Typst-Dateien werden nicht überschrieben
--   - Ungültige Typst-Labels werden automatisch korrigiert
--   - Referenzen werden entsprechend angepasst
--   - Oil wird nach erfolgreicher Konvertierung aktualisiert

local M = {}

-- ---------------------------------------------------------
-- Typst-Labels und Referenzen korrigieren
-- ---------------------------------------------------------

local function fix_labels(path)
  local file, err = io.open(path, "rb")

  if not file then
    return nil, err
  end

  local content = file:read("*a")
  file:close()

  local count = 0

  -- Labels und Referenzen verwenden dieselbe Syntax:
  -- <label>
  --
  -- Deshalb werden beide automatisch identisch korrigiert.
  local updated = content:gsub("<([^<>\r\n]+)>", function(label)
    -- Nur Labels bearbeiten, die tatsächlich Kommas oder
    -- Leerzeichen enthalten.
    if not label:find("[,%s]") then
      return "<" .. label .. ">"
    end

    -- Nur typische Label-Bezeichner berücksichtigen.
    -- Dadurch werden andere Ausdrücke in <...> geschont.
    if not label:match("^[%a][%w_%-]*") then
      return "<" .. label .. ">"
    end

    local fixed = label
      :gsub("[,%s]+", "-") -- Kommas und Leerzeichen ersetzen
      :gsub("%-+", "-") -- Mehrfache Bindestriche entfernen
      :gsub("%-$", "") -- Abschließenden Bindestrich entfernen

    if fixed ~= label then
      count = count + 1
    end

    return "<" .. fixed .. ">"
  end)
  -- Fehlerhafte Längenangaben in #v() korrigieren
  -- Beispiel: #v(20 mm) → #v(20mm)
  updated = updated:gsub("#v%(%s*(%d+%.?%d*)%s+(%a+)%s*%)", function(value, unit)
    local valid_units = {
      mm = true,
      cm = true,
      pt = true,
      em = true,
      ["in"] = true,
    }

    if valid_units[unit] then
      return "#v(" .. value .. unit .. ")"
    end

    return "#v(" .. value .. " " .. unit .. ")"
  end)
  local output, write_err = io.open(path, "wb")

  if not output then
    return nil, write_err
  end

  local ok, result = output:write(updated)

  if not ok then
    output:close()
    return nil, result
  end

  output:close()

  return count
end

-- ---------------------------------------------------------
-- LaTeX → Typst
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

  -- Oil-Fenster und Buffer merken
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  -- -------------------------------------------------------
  -- Konvertierung asynchron ausführen
  -- -------------------------------------------------------

  vim.system({
    "t2l",
    input,
    "-o",
    output,
    "--direction",
    "l2t",
    "--full-document",
    "--pretty",
    "--embed-warnings",
  }, {
    cwd = dir,
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Tylax-Konvertierung fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      -- ---------------------------------------------------
      -- Automatische Nachbearbeitung
      -- ---------------------------------------------------

      local corrected, err = fix_labels(output)

      if corrected == nil then
        vim.notify(
          "Typst-Datei erstellt, aber Nachbearbeitung fehlgeschlagen:\n" .. tostring(err),
          vim.log.levels.ERROR
        )
      else
        vim.notify(
          string.format("Erstellt: %s.typ\n%d Label-/Referenzkorrekturen", basename, corrected),
          vim.log.levels.INFO
        )
      end

      -- ---------------------------------------------------
      -- Oil aktualisieren
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
-- Keymap nur in Oil aktivieren
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
