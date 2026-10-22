local source = {}

local bib_path = vim.fn.expand("~/Library/texmf/bibtex/bib/Zotero.bib")

local cache = {
  mtime = nil,
  items = {},
}

local function get_items()
  local stat = vim.uv.fs_stat(bib_path)

  if not stat then
    return {}
  end

  local mtime = stat.mtime.sec

  if cache.mtime == mtime then
    return cache.items
  end

  local file = io.open(bib_path, "r")

  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()

  local items = {}
  local seen = {}

  for entry_type, key in content:gmatch("@([%a]+)%s*{%s*([^,%s]+)%s*,") do
    if not seen[key] then
      seen[key] = true

      table.insert(items, {
        label = key,
        kind = 18, -- Reference
        detail = entry_type,
        insertText = key,
      })
    end
  end

  cache.mtime = mtime
  cache.items = items

  return items
end

function source:is_available()
  return vim.bo.filetype == "typst"
end

function source:get_trigger_characters()
  return { "<" }
end

function source:complete(params, callback)
  local line = params.context.cursor_before_line

  -- Vorherige Zeilen berücksichtigen (für mehrzeilige #cite-Aufrufe)
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  local start_row = math.max(0, row - 10)

  local previous = vim.api.nvim_buf_get_lines(bufnr, start_row, row - 1, false)

  table.insert(previous, line)

  local context = table.concat(previous, "\n")

  -- Ein- und mehrzeilige #cite(<...)-Aufrufe erkennen
  local prefix = context:match("#cite%s*%(%s*<([%w_%-:]*)$")

  if not prefix then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local items = {}

  for _, item in ipairs(get_items()) do
    if item.label:lower():find(prefix:lower(), 1, true) == 1 then
      table.insert(items, item)
    end
  end

  callback({
    items = items,
    isIncomplete = false,
  })
end

return source
