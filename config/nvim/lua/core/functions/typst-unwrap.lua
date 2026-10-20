local M = {}

local function boundary(line)
  local text = vim.trim(line)
  return text == "" or text:match("^//") or text:match("^/%*")
    or text:match("^%*/") or text:match("^#") or text:match("^=")
    or text:match("^[%-%+]%s") or text:match("^/%s*[^/]")
    or text:match("^%$.*%$$")
    or text:match("^```") or text:match("^%[") or text:match("^%]")
end

function M.unwrap_buffer()
  if vim.bo.filetype ~= "typst" then
    vim.notify("TypstUnwrap ist nur für Typst-Dateien vorgesehen", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local result, paragraph = {}, nil
  local function flush()
    if paragraph then
      result[#result + 1] = paragraph
      paragraph = nil
    end
  end
  local raw, block_comment, math = false, false, false
  for _, line in ipairs(lines) do
    local text = vim.trim(line)
    if raw or block_comment or math or boundary(line) then
      flush()
      result[#result + 1] = line
    else
      paragraph = paragraph and (paragraph .. " " .. text) or text
      if text:match("\\%s*$") then flush() end
    end
    if text:match("^```") then raw = not raw end
    if text:match("/%*") then block_comment = true end
    if text:match("%*/") then block_comment = false end
    if text == "$" then math = not math end
  end
  flush()
  if not vim.deep_equal(lines, result) then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
  end
  vim.notify("Typst-Fließtext zusammengeführt", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("TypstUnwrap", M.unwrap_buffer, { desc = "Typst-Fließtext zu Absätzen zusammenführen" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>vu", M.unwrap_buffer, {
      buffer = args.buf, silent = true, desc = "Typst: Absätze zusammenführen",
    })
  end,
})

return M
