local marker = "% LATEX_FLOAT_OFF "

local float_envs = {
  figure = true,
  ["figure*"] = true,
  table = true,
  ["table*"] = true,
}

local function strip_comment_prefix(line)
  local s = line

  s = s:gsub("^%s*%%+%s*LATEX_FLOAT_OFF%s*", "", 1)
  s = s:gsub("^%s*%%%s?", "", 1)

  return s
end

local function is_blank(line)
  local s = strip_comment_prefix(line)
  return s:match("^%s*$") ~= nil
end

local function begin_env(line)
  local s = strip_comment_prefix(line)
  return s:match("\\begin%s*{%s*([^}]+)%s*}")
end

local function end_env(line)
  local s = strip_comment_prefix(line)
  return s:match("\\end%s*{%s*([^}]+)%s*}")
end

local function is_multicols_begin(line)
  local env = begin_env(line)
  return env == "multicols" or env == "multicols*"
end

local function is_multicols_end(line)
  local env = end_env(line)
  return env == "multicols" or env == "multicols*"
end

local function is_captionof_float(line)
  local s = strip_comment_prefix(line)

  return s:match("\\captionof%s*{%s*figure%s*}") or s:match("\\captionof%s*{%s*table%s*}")
end

local function has_caption(line)
  local s = strip_comment_prefix(line)

  return s:match("\\caption%s*{") or s:match("\\captionof%s*{%s*figure%s*}") or s:match("\\captionof%s*{%s*table%s*}")
end

local function add_marker(line)
  -- Jede Zeile bekommt eine eigene Schicht; vorhandene Kommentare bleiben erhalten.
  if line:match("^%s*%% LATEX_FLOAT_OFF ") then
    return line
  end

  local indent, rest = line:match("^(%s*)(.*)$")
  return indent .. marker .. rest
end

local function uncomment_line(line)
  -- Nur unsere Schicht entfernen, auch bei wiederholtem Einkommentieren.
  local restored = line:gsub("^(%s*)%% LATEX_FLOAT_OFF ", "%1", 1)
  return restored
end

local function find_env_end(lines, start_idx, env_name)
  local depth = 0

  for i = start_idx, #lines do
    local s = strip_comment_prefix(lines[i])

    for command, env in s:gmatch("\\(%a+)%s*{%s*([^}]-)%s*}") do
      if env == env_name then
        if command == "begin" then
          depth = depth + 1
        elseif command == "end" then
          depth = depth - 1
          if depth == 0 then
            return i
          end
        end
      end
    end
  end

  return nil
end

local function is_comment_hint(line)
  return line:lower():match("^%s*%%+%s*dies%s+kommentieren%s*$") ~= nil
end

local function is_uncomment_hint(line)
  return line:lower():match("^%s*%%+%s*dies%s+unkommentieren%s*$") ~= nil
end

local function find_requested_block(lines, hint_idx)
  -- Der Hinweis gilt für die nächste nichtleere Zeile bzw. deren gesamte Umgebung.
  local start_idx = hint_idx + 1
  while start_idx <= #lines and is_blank(lines[start_idx]) do
    start_idx = start_idx + 1
  end

  if start_idx > #lines then
    return nil
  end

  local env = begin_env(lines[start_idx])
  if env then
    return start_idx, find_env_end(lines, start_idx, env)
  end

  return start_idx, start_idx
end

local function extend_block_up(lines, start_idx)
  local i = start_idx - 1

  while i >= 1 and is_blank(lines[i]) do
    i = i - 1
  end

  if i >= 1 and is_multicols_end(lines[i]) then
    return i
  end

  return start_idx
end

local function extend_block_down(lines, end_idx)
  local i = end_idx + 1

  while i <= #lines and is_blank(lines[i]) do
    i = i + 1
  end

  if i <= #lines and is_multicols_begin(lines[i]) then
    return i
  end

  return end_idx
end

local function find_center_block(lines, idx)
  local start_idx

  for i = idx, 1, -1 do
    local s = strip_comment_prefix(lines[i])

    if s:match("\\begin%s*{%s*center%s*}") then
      start_idx = i
      break
    end

    if begin_env(lines[i]) or end_env(lines[i]) then
      break
    end
  end

  if not start_idx then
    return nil
  end

  for i = idx, #lines do
    local s = strip_comment_prefix(lines[i])

    if s:match("\\end%s*{%s*center%s*}") then
      return start_idx, i
    end
  end

  return nil
end

local function find_brace_block(lines, idx)
  local start_idx

  for i = idx, 1, -1 do
    local s = strip_comment_prefix(lines[i])

    if s:match("^%s*{%s*\\centering") or s:match("^%s*{%s*$") then
      start_idx = i
      break
    end
  end

  if not start_idx then
    return nil
  end

  local depth = 0
  local started = false
  local max_line = math.min(start_idx + 120, #lines)

  for i = start_idx, max_line do
    local s = strip_comment_prefix(lines[i])

    for brace in s:gmatch("[{}]") do
      if brace == "{" then
        depth = depth + 1
        started = true
      elseif brace == "}" then
        depth = depth - 1
      end
    end

    if started and depth == 0 then
      -- Der Block muss die Caption enthalten. Ein früher abgeschlossener Block
      -- würde den aufrufenden Durchlauf zurücksetzen und endlos wiederholen.
      if i >= idx then
        return start_idx, i
      end
      return nil
    end
  end

  return nil
end

-- local function should_skip_float(lines, float_start)
--   if float_start <= 1 then
--     return false
--   end
--
--   local line_above = lines[float_start - 1]
--
--   return line_above:lower():match("^%s*%%%s*nicht%s+kommentieren%s*$") ~= nil
-- end
local function should_skip_float(lines, float_start)
  local i = float_start - 1

  -- Leere Zeilen zwischen Hinweis und Float erlauben
  while i >= 1 and lines[i]:match("^%s*$") do
    i = i - 1
  end

  if i < 1 then
    return false
  end

  local line = lines[i]:lower()

  -- Erlaubt:
  -- % nicht kommentieren
  -- %% nicht kommentieren
  -- %   nicht   kommentieren
  return line:match("^%s*%%+%s*nicht%s+kommentieren%s*$") ~= nil
end
local function comment_block(lines, block_start, block_end)
  for i = block_start, block_end do
    lines[i] = add_marker(lines[i])
  end
end

local function uncomment_block(lines, block_start, block_end)
  for i = block_start, block_end do
    lines[i] = uncomment_line(lines[i])
  end
end

local function activate_block(lines, block_start, block_end)
  -- Bei manuell kommentierten Blöcken genau eine %-Schicht entfernen.
  -- Ein bereits aktiver Block behält seine internen Kommentare auch bei Wiederholung.
  local manually_commented = uncomment_line(lines[block_start]):match("^%s*%%") ~= nil

  for i = block_start, block_end do
    local line = uncomment_line(lines[i])
    if manually_commented then
      line = line:gsub("^(%s*)%%%s?", "%1", 1)
    end
    lines[i] = line
  end
end

local function apply_float_comments(lines, comment)
  if not comment then
    -- Bilder und ausdrücklich ausgeblendete Texte wiederherstellen.
    uncomment_block(lines, 1, #lines)

    -- Inhalte mit diesem Hinweis gehören nur in die Version ohne Bilder.
    -- Beim Zurückschalten werden sie wieder ausgeblendet.
    local i = 1
    while i <= #lines do
      if is_uncomment_hint(lines[i]) then
        local block_start, block_end = find_requested_block(lines, i)
        if block_start and block_end then
          if not lines[block_start]:match("^%s*%%") then
            comment_block(lines, block_start, block_end)
          end
          i = block_end
        end
      end
      i = i + 1
    end

    return
  end

  local i = 1

  while i <= #lines do
    local block_start
    local block_end
    local actual_start
    local skip_commenting = false
    local activate = is_uncomment_hint(lines[i])

    local env = begin_env(lines[i])

    if activate or is_comment_hint(lines[i]) then
      actual_start = i
      block_start, block_end = find_requested_block(lines, i)
    elseif env and float_envs[env] then
      local float_start = i
      local float_end = find_env_end(lines, float_start, env)

      if float_end then
        actual_start = float_start
        block_start = extend_block_up(lines, float_start)
        block_end = extend_block_down(lines, float_end)
      end
    elseif is_captionof_float(lines[i]) then
      local center_start, center_end = find_center_block(lines, i)

      if center_start and center_end then
        actual_start = center_start
        block_start = extend_block_up(lines, center_start)
        block_end = extend_block_down(lines, center_end)
      else
        local brace_start, brace_end = find_brace_block(lines, i)

        if brace_start and brace_end then
          actual_start = brace_start
          block_start = extend_block_up(lines, brace_start)
          block_end = extend_block_down(lines, brace_end)
        end
      end
    elseif has_caption(lines[i]) then
      local center_start, center_end = find_center_block(lines, i)

      if center_start and center_end then
        actual_start = center_start
        block_start = extend_block_up(lines, center_start)
        block_end = extend_block_down(lines, center_end)
      end
    end

    if block_start and block_end then
      if actual_start then
        skip_commenting = should_skip_float(lines, actual_start)
      end

      if activate then
        activate_block(lines, block_start, block_end)
      elseif not skip_commenting then
        comment_block(lines, block_start, block_end)
      end

      i = math.max(i + 1, block_end + 1)
    else
      i = i + 1
    end
  end

end

local function set_float_comments(comment)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  apply_float_comments(lines, comment)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

local function toggle_float_comments()
  local bufnr = vim.api.nvim_get_current_buf()
  local original = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local lines = vim.deepcopy(original)
  apply_float_comments(lines, true)

  -- Ist die Version ohne Bilder bereits aktiv, zur Version mit Bildern wechseln.
  -- Auch die umgekehrten Hinweise „dies unkommentieren“ werden berücksichtigt.
  if vim.deep_equal(lines, original) then
    apply_float_comments(lines, false)
  end

  if not vim.deep_equal(lines, original) then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end
end

local function uncomment_range(start_line, end_line)
  local bufnr = vim.api.nvim_get_current_buf()

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  for i, line in ipairs(lines) do
    lines[i] = uncomment_line(line)
  end

  vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, lines)
end

vim.api.nvim_create_user_command("LatexCommentFloats", function()
  set_float_comments(true)
end, {
  force = true,
  desc = "Comment out LaTeX floats and apply explicit comment/uncomment hints",
})

vim.api.nvim_create_user_command("LatexUncommentFloats", function()
  set_float_comments(false)
end, {
  force = true,
  desc = "Restore LaTeX floats and hide content marked for activation",
})

vim.api.nvim_create_user_command("LatexUncommentSelection", function(opts)
  uncomment_range(opts.line1, opts.line2)
end, {
  force = true,
  range = true,
  desc = "Selected LaTeX lines uncomment",
})

vim.api.nvim_create_user_command("LatexToggleFloats", toggle_float_comments, {
  force = true,
  desc = "Toggle LaTeX float comments and explicit comment/uncomment hints",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex" },
  callback = function(args)
    vim.keymap.set("n", "<localleader>vx", toggle_float_comments, {
      buffer = args.buf,
      silent = true,
      desc = "Toggle LaTeX figure/table comments",
    })
  end,
})

vim.keymap.set("x", "<localleader>gc", ":<C-u>'<,'>LatexUncommentSelection<CR>", {
  silent = true,
  desc = "Uncomment selected LaTeX lines",
})
