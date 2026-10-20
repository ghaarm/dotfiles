local M = {}
local image_preview = require("core.functions.bild-preview-mac")

local function image_path()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2] + 1
  local from = 1
  local first_path
  while true do
    local start_pos, end_pos, path = line:find('#?image%s*%(%s*"([^"]+)"', from)
    if not start_pos then break end
    first_path = first_path or path
    if cursor >= start_pos and cursor <= end_pos then return path end
    from = end_pos + 1
  end
  return first_path
end

local function resolved_path()
  if vim.bo.filetype ~= "typst" then return nil end
  local path = image_path()
  if not path then
    vim.notify("Kein Typst-Bildpfad unter dem Cursor gefunden", vim.log.levels.WARN)
    return nil
  end
  local source = vim.api.nvim_buf_get_name(0)
  local fullpath = path:sub(1, 1) == "/" and path or vim.fs.joinpath(vim.fs.dirname(source), path)
  fullpath = vim.fs.normalize(fullpath)
  if vim.fn.filereadable(fullpath) ~= 1 then
    vim.notify("Bilddatei nicht gefunden:\n" .. fullpath, vim.log.levels.ERROR)
    return nil
  end
  return fullpath
end

function M.preview()
  local path = resolved_path()
  if path then image_preview.open_path_in_preview(path) end
end

function M.open_in_oil()
  local path = resolved_path()
  if path then image_preview.open_path_in_oil(path) end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "ga", M.preview,
      { buffer = args.buf, silent = true, desc = "Typst-Bild in Preview öffnen" })
    vim.keymap.set("n", "gp", M.open_in_oil,
      { buffer = args.buf, silent = true, desc = "Typst-Bild in Oil anzeigen" })
  end,
})

return M
