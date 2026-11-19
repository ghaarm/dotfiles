-- PDF-Datei aus Oil drucken
--
-- ,p: PDF unter dem Cursor an den Standarddrucker senden

local M = {}

function M.print_pdf()
  local oil = require("oil")

  local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()

  if not entry or not dir or entry.type ~= "file" then
    vim.notify("Bitte eine PDF-Datei in Oil auswählen.", vim.log.levels.WARN)
    return
  end

  -- Nur PDF-Dateien zulassen
  if not entry.name:lower():match("%.pdf$") then
    vim.notify("Die ausgewählte Datei ist keine PDF-Datei.", vim.log.levels.WARN)
    return
  end

  local path = vim.fs.joinpath(dir, entry.name)

  if not vim.uv.fs_stat(path) then
    vim.notify("PDF-Datei nicht gefunden: " .. path, vim.log.levels.ERROR)
    return
  end

  -- PDF asynchron an den macOS-Standarddrucker senden
  vim.system({
    "lp",
    "--",
    path,
  }, {
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Druckauftrag fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      vim.notify("Druckauftrag gesendet:\n" .. entry.name .. "\n" .. vim.trim(result.stdout or ""), vim.log.levels.INFO)
    end)
  end)
end

-- Keymap ausschließlich in Oil aktivieren
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function(args)
    vim.keymap.set("n", ",p", M.print_pdf, {
      buffer = args.buf,
      silent = true,
      desc = "Oil: PDF drucken",
    })
  end,
})

return M
