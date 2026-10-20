local M = {}
local marker = "// TYPST_FLOAT_OFF "

local function marked(line)
  return line:match("^%s*// TYPST_FLOAT_OFF ") ~= nil
end

local function add_marker(line)
  if marked(line) then return line end
  local indent, rest = line:match("^(%s*)(.*)$")
  return indent .. marker .. rest
end

local function remove_marker(line)
  return (line:gsub("^(%s*)// TYPST_FLOAT_OFF ", "%1", 1))
end

local function visible(line)
  return remove_marker(line)
end

local function hint(line, words)
  return visible(line):lower():match("^%s*//+%s*" .. words .. "%s*$") ~= nil
end

-- Finds the end of a #figure(...) or #table(...) call, including nested calls.
local function figure_end(lines, start_idx)
  local depth, quote, block_comment = 0, nil, false
  local started = false
  for i = start_idx, #lines do
    local line = visible(lines[i])
    local j = 1
    while j <= #line do
      local char, next_char = line:sub(j, j), line:sub(j + 1, j + 1)
      if block_comment then
        if char == "*" and next_char == "/" then block_comment = false; j = j + 1 end
      elseif quote then
        if char == "\\" then j = j + 1
        elseif char == quote then quote = nil end
      elseif char == "/" and next_char == "/" then
        break
      elseif char == "/" and next_char == "*" then
        block_comment = true; j = j + 1
      elseif char == '"' or char == "'" then
        quote = char
      elseif char == "(" or char == "[" or char == "{" then
        depth = depth + 1
        started = true
      elseif char == ")" or char == "]" or char == "}" then
        depth = depth - 1
        if started and depth == 0 then return i end
      end
      j = j + 1
    end
  end
  return nil
end

local function requested_end(lines, index)
  local start_idx = index + 1
  while start_idx <= #lines and vim.trim(visible(lines[start_idx])) == "" do
    start_idx = start_idx + 1
  end
  if start_idx > #lines then return nil end
  if visible(lines[start_idx]):match("^%s*#figure%s*%(")
    or visible(lines[start_idx]):match("^%s*#table%s*%(") then
    return start_idx, figure_end(lines, start_idx)
  end
  return start_idx, start_idx
end

local function set_block(lines, first, last, comment)
  for i = first, last do
    lines[i] = comment and add_marker(lines[i]) or remove_marker(lines[i])
  end
end

local function apply(lines, comment)
  if not comment then
    set_block(lines, 1, #lines, false)
  end
  local i = 1
  while i <= #lines do
    local first, last, activate
    if hint(lines[i], "dies%s+kommentieren") or hint(lines[i], "dies%s+unkommentieren") then
      activate = hint(lines[i], "dies%s+unkommentieren")
      first, last = requested_end(lines, i)
    elseif comment and (visible(lines[i]):match("^%s*#figure%s*%(")
      or visible(lines[i]):match("^%s*#table%s*%(")) then
      first, last = i, figure_end(lines, i)
    end

    if first and last then
      local skip = false
      local above = i - 1
      while above > 0 and vim.trim(visible(lines[above])) == "" do above = above - 1 end
      if above > 0 then skip = hint(lines[above], "nicht%s+kommentieren") end
      if comment then
        if activate then
          set_block(lines, first, last, false)
          -- Activate one preexisting manual // layer, if present.
          if visible(lines[first]):match("^%s*//") then
            for n = first, last do
              lines[n] = lines[n]:gsub("^(%s*)//%s?", "%1", 1)
            end
          end
        elseif not skip then
          set_block(lines, first, last, true)
        end
      elseif activate then
        set_block(lines, first, last, true)
      end
      i = last + 1
    else
      i = i + 1
    end
  end
end

local function edit(comment, toggle)
  if vim.bo.filetype ~= "typst" then
    vim.notify("Bitte eine Typst-Datei öffnen", vim.log.levels.WARN)
    return
  end
  local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local after = vim.deepcopy(before)
  apply(after, comment)
  if toggle and vim.deep_equal(before, after) then apply(after, false) end
  if not vim.deep_equal(before, after) then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, after)
  end
end

function M.comment() edit(true, false) end
function M.uncomment() edit(false, false) end
function M.toggle() edit(true, true) end

vim.api.nvim_create_user_command("TypstCommentFloats", M.comment, { desc = "Typst-Abbildungen auskommentieren" })
vim.api.nvim_create_user_command("TypstUncommentFloats", M.uncomment, { desc = "Typst-Abbildungen wiederherstellen" })
vim.api.nvim_create_user_command("TypstToggleFloats", M.toggle, { desc = "Typst-Abbildungen umschalten" })
vim.api.nvim_create_user_command("TypstUncommentSelection", function(opts)
  if vim.bo.filetype ~= "typst" then return end
  local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
  for i, line in ipairs(lines) do lines[i] = remove_marker(line) end
  vim.api.nvim_buf_set_lines(0, opts.line1 - 1, opts.line2, false, lines)
end, { range = true, desc = "Typst-Kommentar-Markierung in Auswahl entfernen" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>vx", M.toggle, {
      buffer = args.buf, silent = true, desc = "Typst-Abbildungen umschalten",
    })
    vim.keymap.set("x", "<localleader>gc", ":<C-u>'<,'>TypstUncommentSelection<CR>", {
      buffer = args.buf, silent = true, desc = "Typst-Auswahl wiederherstellen",
    })
  end,
})

return M
