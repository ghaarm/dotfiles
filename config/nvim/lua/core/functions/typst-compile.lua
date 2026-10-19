local M = {}

function M.compile()
  local buf = vim.api.nvim_get_current_buf()
  local source = vim.api.nvim_buf_get_name(buf)

  if source == "" or vim.bo[buf].filetype ~= "typst" then
    vim.notify("Keine Typst-Datei geöffnet", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable("typst") == 0 then
    vim.notify("Typst ist nicht im PATH", vim.log.levels.ERROR)
    return
  end

  local saved, err = pcall(vim.cmd, "silent update")
  if not saved then
    vim.notify("Typst-Datei konnte nicht gespeichert werden: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local output = vim.fn.fnamemodify(source, ":r") .. ".pdf"
  -- Root / erlaubt die absoluten Imports in der KN-Touying-Vorlage.
  vim.system({ "typst", "compile", "--root", "/", source, output }, {
    cwd = vim.fs.dirname(source),
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Typst-PDF erstellt: " .. output)
      else
        local details = (result.stderr or ""):gsub("%s+$", "")
        if details == "" then
          details = (result.stdout or ""):gsub("%s+$", "")
        end
        vim.notify("Typst-Kompilierung fehlgeschlagen:\n" .. details, vim.log.levels.ERROR)
      end
    end)
  end)
end

local group = vim.api.nvim_create_augroup("TypstCompileMapping", { clear = true })
local function set_map(buf)
  vim.keymap.set("n", "<localleader>lf", M.compile, {
    buffer = buf,
    silent = true,
    desc = "Typst: PDF kompilieren",
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "typst",
  callback = function(args)
    set_map(args.buf)
  end,
})

if vim.bo.filetype == "typst" then
  set_map(vim.api.nvim_get_current_buf())
end

return M
