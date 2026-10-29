local M = {}

-- The marker is part of a task title so kanban.nvim's reader and writer keep it.
-- The board conceals it; the Markdown file remains self-describing after a restart.
local marker_pattern = " <!%-%- kanban%-next%-action:([%da-f]+) %-%->"

local function marker(id)
  return " <!-- kanban-next-action:" .. id .. " -->"
end

local function project_tag(source)
  local name = vim.fn.fnamemodify(source, ":t"):gsub("%.md$", ""):gsub("^kanban%-", "")
  return "#" .. name:gsub("%s+", "-")
end

local function tagged_action(action, source)
  local tag = project_tag(source)
  if action:sub(-#tag) == tag and (action:sub(-#tag - 1, -#tag - 1):match("%s") or #action == #tag) then
    return action
  end
  return action .. " " .. tag
end

local function next_text(lines)
  local found, found_index
  for i = 2, #lines do
    local value = lines[i]:match("^%s*Next:%s*(.-)%s*$")
    if value then
      if found ~= nil then
        return nil, nil, "duplicate"
      end
      found, found_index = value, i
    end
  end
  return found, found_index
end

local function identity(task)
  local body = {}
  for i = 2, #task.lines do
    local line = vim.trim(task.lines[i])
    if line ~= "" and not line:match("^Next:") then
      body[#body + 1] = line
    end
  end
  return { title = task.lines[1], body = body }
end

local function same_body(a, b)
  if #a ~= #b then
    return false
  end
  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end

local function parse_tasks(lines)
  local tasks, section, current = {}, nil, nil
  for i, line in ipairs(lines) do
    if line:match("^%%%% kanban:settings") then
      break
    end
    local heading = line:match("^##%s+(.+)$")
    if heading then
      section = heading:upper():match("^(TODO)") or heading:upper():match("^(WIP)") or heading:upper():match("^(DONE)")
      current = nil
    elseif line:match("^#%s+") then
      current = nil
    else
      local title = line:match("^%- %[.%] (.*)$")
      if title and section then
        current = { title = title, section = section, start_line = i, end_line = i, lines = { title } }
        tasks[#tasks + 1] = current
      elseif current and vim.trim(line) ~= "" then
        current.end_line = i
        current.lines[#current.lines + 1] = line:gsub("^%s+", "")
      end
    end
  end
  return tasks
end

local function find_id(tasks, id)
  local found
  for _, task in ipairs(tasks) do
    if task.title:match(marker_pattern .. "$") == id then
      if found then
        return nil, "duplicate"
      end
      found = task
    end
  end
  return found
end

local function find_parent(tasks, entry)
  local found
  for _, task in ipairs(tasks) do
    local candidate = identity(task)
    if candidate.title == entry.parent_title and same_body(candidate.body, entry.parent_body or {}) then
      if found then
        return nil, "duplicate"
      end
      found = task
    end
  end
  return found
end

local function id_for(metadata)
  local id
  repeat
    id = vim.fn.sha256(tostring(vim.uv.hrtime()) .. tostring(math.random()) .. tostring(os.time())):sub(1, 20)
  until metadata[id] == nil
  return id
end

function M.action_from_task(task)
  local value, _, err = next_text(task.lines)
  return value and value ~= "" and value or nil, err
end

function M.has_marker(title)
  return title:match(marker_pattern .. "$") ~= nil
end

function M.add(task, ctx)
  local action = M.action_from_task(task)
  if not action then
    return false
  end

  local source_lines = ctx.read_lines(task.source)
  local today_lines = ctx.read_lines(ctx.today)
  if not source_lines or not today_lines then
    ctx.notify("Projekt oder Tages-Kanban konnte nicht gelesen werden.", vim.log.levels.ERROR)
    return true
  end
  if not ctx.can_modify_file(ctx.today) then
    return true
  end

  local parent_identity = identity(task)
  local parent, parent_error = find_parent(parse_tasks(source_lines), {
    parent_title = parent_identity.title,
    parent_body = parent_identity.body,
  })
  if parent_error or not parent or next_text(parent.lines) ~= action then
    ctx.notify("Projektkarte ist nicht eindeutig oder Next wurde noch nicht gespeichert.", vim.log.levels.WARN)
    return true
  end

  local parent_id
  for id, entry in pairs(ctx.metadata) do
    if entry.type == "next_action" and entry.source == task.source
      and entry.parent_title == parent_identity.title
      and same_body(entry.parent_body or {}, parent_identity.body) then
      parent_id = entry.parent_id or id
      if entry.action == action and not entry.completed then
        local existing = find_id(parse_tasks(today_lines), id)
        if existing then
          ctx.notify("Diese Next Action wurde bereits nach Heute übernommen.")
          return true
        end
        -- An interrupted transfer is safe to resume with its original ID.
        return M.insert_today(id, action, today_lines, ctx)
      end
    end
  end

  local id = id_for(ctx.metadata)
  ctx.metadata[id] = {
    type = "next_action", source = task.source,
    parent_id = parent_id or id_for(ctx.metadata),
    parent_title = parent_identity.title, parent_body = parent_identity.body,
    action = action, completed = false,
  }
  if not ctx.save_metadata(ctx.metadata) then
    return true
  end
  return M.insert_today(id, action, today_lines, ctx)
end

function M.insert_today(id, action, lines, ctx)
  local insert_at = ctx.find_task_insert_position(lines, "TODO")
  if not insert_at then
    ctx.notify("TODO-Spalte im Tages-Kanban fehlt.", vim.log.levels.ERROR)
    return true
  end
  local entry = ctx.metadata[id]
  table.insert(lines, insert_at, "- [ ] " .. tagged_action(action, entry.source) .. marker(id))
  table.insert(lines, insert_at + 1, "")
  if ctx.write_lines(ctx.today, lines) then
    ctx.reload_buffer(ctx.today)
    ctx.notify("Next Action nach Heute übernommen: " .. action)
  end
  return true
end

function M.sync(changed, ctx)
  local today_lines = ctx.read_lines(ctx.today)
  if not today_lines then
    return
  end
  local today_tasks = parse_tasks(today_lines)
  local metadata_changed = false

  -- Ältere Heute-Karten bekommen ihren Projekttag beim nächsten sicheren Sync.
  local today_changed = false
  for id, entry in pairs(ctx.metadata) do
    if entry.type == "next_action" and entry.source then
      local task, duplicate = find_id(today_tasks, id)
      if task and not duplicate then
        local line = today_lines[task.start_line]
        local suffix = marker(id)
        local title = line:sub(1, -#suffix - 1)
        local with_tag = tagged_action(title, entry.source)
        if with_tag ~= title then
          today_lines[task.start_line] = with_tag .. suffix
          today_changed = true
        end
      end
    end
  end
  if today_changed and ctx.can_modify_file(ctx.today) then
    if ctx.write_lines(ctx.today, today_lines) then
      ctx.reload_buffer(ctx.today)
      today_tasks = parse_tasks(today_lines)
    end
  end

  for id, entry in pairs(ctx.metadata) do
    if entry.type == "next_action" and (changed == ctx.today or changed == entry.source) then
      local today_task, today_error = find_id(today_tasks, id)
      if today_error then
        ctx.notify("Next Action ist in Heute mehrfach vorhanden: " .. entry.action, vim.log.levels.WARN)
      elseif entry.completed then
        if today_task and today_task.section ~= "DONE" then
          ctx.notify("Abgeschlossene Next Action wurde in Heute zurückverschoben; Projektabschluss bleibt bestehen: " .. entry.action, vim.log.levels.WARN)
        end
      elseif today_task and today_task.section == "DONE" then
        local source_lines = ctx.read_lines(entry.source)
        if not source_lines then
          ctx.notify("Projektdatei der Next Action fehlt: " .. entry.action, vim.log.levels.WARN)
        elseif not ctx.can_modify_file(entry.source) then
          -- Retry on the next save.
        else
          local source_tasks = parse_tasks(source_lines)
          local parent, parent_error = find_parent(source_tasks, entry)
          local done, done_error = find_id(source_tasks, id)
          local current_next = parent and next_text(parent.lines)
          if parent_error or done_error or not parent then
            ctx.notify("Projektkarte der Next Action fehlt oder ist mehrdeutig: " .. entry.action, vim.log.levels.WARN)
          elseif current_next ~= entry.action and not (done and current_next == "") then
            ctx.notify("Konflikt: Next wurde im Projekt geändert: " .. entry.action, vim.log.levels.WARN)
          elseif done and done.section ~= "DONE" then
            ctx.notify("Konflikt: Abschlusskarte steht nicht in DONE: " .. entry.action, vim.log.levels.WARN)
          elseif not done and not ctx.find_task_insert_position(source_lines, "DONE") then
            ctx.notify("DONE-Spalte im Projekt fehlt: " .. entry.action, vim.log.levels.ERROR)
          else
            if current_next == entry.action then
              local next_line = parent.start_line
              for i = parent.start_line + 1, parent.end_line do
                if source_lines[i]:match("^%s*Next:") then
                  next_line = i
                  break
                end
              end
              source_lines[next_line] = source_lines[next_line]:gsub("^(%s*Next:).*", "%1")
            end
            if not done then
              local insert_at = ctx.find_task_insert_position(source_lines, "DONE")
              table.insert(source_lines, insert_at, "- [x] " .. entry.action .. marker(id))
              table.insert(source_lines, insert_at + 1, "")
            end
            if ctx.write_lines(entry.source, source_lines) then
              ctx.reload_buffer(entry.source)
              entry.completed = true
              metadata_changed = true
              ctx.notify("Next Action im Projekt abgeschlossen: " .. entry.action)
            end
          end
        end
      end
    end
  end

  if metadata_changed and not ctx.save_metadata(ctx.metadata) then
    ctx.notify("Projektabschluss geschrieben; Metadaten werden beim nächsten Speichern nachgetragen.", vim.log.levels.ERROR)
  end
end

return M
