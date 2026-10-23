local M = {}

local namespace = vim.api.nvim_create_namespace("OilSelection")
local selections = {}

local function redraw(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local state = selections[bufnr]
  if not state then
    return
  end

  local oil = require("oil")
  local visible = {}
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  for lnum = 1, vim.api.nvim_buf_line_count(bufnr) do
    local entry = oil.get_entry_on_line(bufnr, lnum)
    if entry and state.names[entry.name] then
      visible[entry.name] = true
      vim.api.nvim_buf_set_extmark(bufnr, namespace, lnum - 1, 0, {
        line_hl_group = "Visual",
        sign_text = "✓",
        sign_hl_group = "DiagnosticOk",
      })
    end
  end

  -- Einträge, die nach einem Refresh oder Speichern nicht mehr existieren,
  -- sollen nicht unbemerkt in einer späteren Aktion verwendet werden.
  for name in pairs(state.names) do
    if not visible[name] then
      state.names[name] = nil
    end
  end
end

local function ensure_state(bufnr)
  if selections[bufnr] then
    return selections[bufnr]
  end

  local state = { names = {}, pending = false }
  selections[bufnr] = state

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function()
      if state.pending then
        return
      end
      state.pending = true
      vim.schedule(function()
        state.pending = false
        redraw(bufnr)
      end)
    end,
    on_detach = function()
      selections[bufnr] = nil
    end,
  })

  return state
end

function M.toggle()
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  if not entry then
    return
  end

  if not entry.id then
    vim.notify("Oil-Eintrag zuerst speichern.", vim.log.levels.INFO)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local state = ensure_state(bufnr)
  state.names[entry.name] = not state.names[entry.name] or nil
  redraw(bufnr)
end

function M.get_selected_paths()
  local bufnr = vim.api.nvim_get_current_buf()
  local state = selections[bufnr]
  if not state or not next(state.names) then
    return nil
  end

  local oil = require("oil")
  local dir = oil.get_current_dir(bufnr)
  if not dir then
    return nil
  end

  local paths = {}
  for lnum = 1, vim.api.nvim_buf_line_count(bufnr) do
    local entry = oil.get_entry_on_line(bufnr, lnum)
    if entry and state.names[entry.name] then
      paths[#paths + 1] = vim.fs.joinpath(dir, entry.name)
    end
  end

  return #paths > 0 and paths or nil
end

return M
