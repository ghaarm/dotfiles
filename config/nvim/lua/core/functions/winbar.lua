-- tj devries https://www.youtube.com/watch?v=LKW_SUucO-k&list=PLMLyZFWQbxIzctnJSWserv5InbRwHm-oW&index=24
--
local M = {}
local dir_levels = 1

function M.kanban_project_name(buf)
  local kanban = package.loaded.kanban
  if not kanban or not kanban.active or not kanban.items or not kanban.kanban_md_path then
    return nil
  end

  local items = kanban.items
  local belongs_to_board = items.kwindow and items.kwindow.buf_nr == buf
  if not belongs_to_board then
    for _, list in ipairs(items.lists or {}) do
      if list.buf_nr == buf then
        belongs_to_board = true
        break
      end
      for _, task in ipairs(list.tasks or {}) do
        if task.buf_nr == buf then
          belongs_to_board = true
          break
        end
      end
      if belongs_to_board then
        break
      end
    end
  end
  if not belongs_to_board then
    return nil
  end

  local name = vim.fs.basename(kanban.kanban_md_path):gsub("^kanban%-", ""):gsub("%.md$", "")
  return name
end

-- local function tail_path(path, n_dirs)
--   if path == "" then
--     return "[No Name]"
--   end
--
--   local parts = vim.split(path, "/", { plain = true })
--
--   if #parts <= n_dirs + 1 then
--     return table.concat(parts, "/")
--   end
--
--   local start_idx = #parts - n_dirs
--   local out = {}
--
--   for i = start_idx, #parts do
--     table.insert(out, parts[i])
--   end
--
--   return table.concat(out, "/")
-- end
local function tail_path(path, n_dirs)
  if path == "" then
    return "[No Name]"
  end

  local parts = vim.split(path, "/", { plain = true })
  parts = vim.tbl_filter(function(p)
    return p ~= ""
  end, parts)

  if #parts == 0 then
    return "[No Name]"
  end

  local file = parts[#parts]
  local dirs = {}

  local start_idx = math.max(1, #parts - n_dirs)
  for i = start_idx, #parts - 1 do
    table.insert(dirs, parts[i])
  end

  if #dirs == 0 then
    return file
  end

  return file .. " <- " .. table.concat(vim.fn.reverse(dirs), "/")
end

function M.render()
  local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)

  local ft = vim.bo[bufnr].filetype
  local name = vim.api.nvim_buf_get_name(bufnr)
  local modified = vim.bo[bufnr].modified and "[+]" or ""

  -- Alpha-Startseite ausblenden
  if ft == "alpha" or ft == "oil" then
    return ""
  end

  local project = M.kanban_project_name(bufnr)
  if project then
    return "%=" .. " " .. project
  end

  -- unbenannten/leeren Buffer ausblenden
  -- if name == "" then
  --   return ""
  -- end

  local shown = tail_path(name, dir_levels)
  return "%=" .. modified .. " " .. shown
end

function M.setup()
  vim.o.winbar = "%!v:lua.require'core.functions.winbar'.render()"
end

return M
