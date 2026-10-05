-- ~/.config/nvim/lua/core/functions/latex-unwrap.lua
--
-- Verbindet umgebrochene LaTeX-Fließtextzeilen zu Absätzen.
--
-- Bleiben als Grenzen erhalten:
--   - Leerzeilen
--   - Kommentare
--   - LaTeX-Befehle am Zeilenanfang
--   - \\
--   - \par
--   - Display-Math
--
-- Command:
--   :LatexUnwrap
--
-- Mapping:
--   <localleader>ju

local M = {}

-- ---------------------------------------------------------
-- Hilfsfunktionen
-- ---------------------------------------------------------

local function trim(line)
  return vim.trim(line)
end

local function is_blank(line)
  return line:match("^%s*$") ~= nil
end

local function is_comment(line)
  return line:match("^%s*%%") ~= nil
end

local function starts_with_command(line)
  return line:match("^%s*\\[%a@]+") ~= nil
end

local function is_display_math(line)
  local text = trim(line)

  return text == "\\[" or text == "\\]" or text == "$$"
end

local function ends_with_linebreak(line)
  local text = trim(line)

  -- LaTeX-Zeilenumbruch: \\
  return text:match("\\\\%s*$") ~= nil
end

local function ends_with_par(line)
  local text = trim(line)

  -- explizites \par am Zeilenende
  return text:match("\\par%s*$") ~= nil
end

local function is_boundary(line)
  return is_blank(line) or is_comment(line) or starts_with_command(line) or is_display_math(line)
end

local function prevents_join_after(line)
  return ends_with_linebreak(line) or ends_with_par(line)
end

-- ---------------------------------------------------------
-- Fließtext zusammenführen
-- ---------------------------------------------------------

local function unwrap_lines(lines)
  local result = {}
  local paragraph = nil

  local function flush_paragraph()
    if paragraph then
      table.insert(result, paragraph)
      paragraph = nil
    end
  end

  for _, line in ipairs(lines) do
    if is_boundary(line) then
      -- Aktuellen Fließtext zuerst abschließen
      flush_paragraph()

      -- Grenze unverändert übernehmen
      table.insert(result, line)
    else
      local text = trim(line)

      if not paragraph then
        paragraph = text
      else
        paragraph = paragraph .. " " .. text
      end

      -- Nach \\ oder \par nicht weiter verbinden
      if prevents_join_after(line) then
        flush_paragraph()
      end
    end
  end

  flush_paragraph()

  return result
end

-- ---------------------------------------------------------
-- Gesamten Buffer bearbeiten
-- ---------------------------------------------------------

function M.unwrap_buffer()
  if vim.bo.filetype ~= "tex" and vim.bo.filetype ~= "plaintex" then
    vim.notify("LatexUnwrap ist nur für LaTeX-Dateien vorgesehen.", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local new_lines = unwrap_lines(lines)

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)

  vim.notify("LaTeX-Fließtext zusammengeführt", vim.log.levels.INFO)
end

-- ---------------------------------------------------------
-- Command
-- ---------------------------------------------------------

vim.api.nvim_create_user_command("LatexUnwrap", function()
  M.unwrap_buffer()
end, {
  desc = "LaTeX-Fließtext zu Absätzen zusammenführen",
})

-- ---------------------------------------------------------
-- Mapping nur für LaTeX
-- ---------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "tex",
    "plaintex",
  },

  callback = function(args)
    vim.keymap.set("n", "<localleader>vu", function()
      M.unwrap_buffer()
    end, {
      buffer = args.buf,
      desc = "LaTeX: Unwrap paragraphs",
    })
  end,
})

return M
