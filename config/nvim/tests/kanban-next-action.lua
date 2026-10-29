vim.opt.rtp:prepend(vim.fn.getcwd() .. "/config/nvim")
vim.opt.swapfile = false

local function run()
  local sync = require("core.functions.kanban-heute-sync")
  local dir = vim.fn.tempname()
  assert(vim.fn.mkdir(dir, "p") == 1)
  local project = dir .. "/kanban-projekt.md"
  local today = dir .. "/kanban-heute.md"
  local footer = { "%% kanban:settings", "{\"keep\":true}", "%%" }
  local function write(path, lines)
    assert(vim.fn.writefile(lines, path) == 0)
  end
  local function read(path)
    return vim.fn.readfile(path)
  end
  local function count(lines, pattern)
    local n = 0
    for _, line in ipairs(lines) do
      if line:match(pattern) then n = n + 1 end
    end
    return n
  end
  local function line_of(lines, pattern)
    for i, line in ipairs(lines) do
      if line:match(pattern) then return i end
    end
  end
  local function select_task(path, pattern)
    vim.cmd("edit! " .. vim.fn.fnameescape(path))
    local line = assert(line_of(vim.api.nvim_buf_get_lines(0, 0, -1, false), pattern))
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  end
  local function move_today(pattern, section, trigger)
    local lines = read(today)
    local index = assert(line_of(lines, pattern))
    local task = table.remove(lines, index)
    task = task:gsub("^%- %[[ xX]%]", section == "DONE" and "- [x]" or "- [ ]")
    local heading = assert(line_of(lines, "^## " .. section))
    table.insert(lines, heading + 1, task)
    write(today, lines)
    sync.sync_file(trigger or today)
  end

  write(project, {
    "## TODO", "", "- [ ] Parent A", "    Note: behalten", "    Next: Gleiche Handlung", "",
    "- [ ] Parent B", "\tNext: Gleiche Handlung", "", "## WIP (max. 3)", "", "## DONE", "", unpack(footer),
  })
  write(today, { "## TODO", "", "## WIP (max. 3)", "", "## DONE", "", unpack(footer) })
  sync.config.today_file = today

  select_task(project, "Parent A")
  sync.add_current_task()
  assert(count(read(today), "^%- %[ %] Gleiche Handlung #projekt <!%-%- kanban%-next%-action:") == 1)
  assert(count(read(project), "Next: Gleiche Handlung") == 2)
  sync.add_current_task()
  assert(count(read(today), "kanban%-next%-action:") == 1)

  select_task(project, "Parent B")
  sync.add_current_task()
  assert(count(read(today), "kanban%-next%-action:") == 2)
  local metadata_path = dir .. "/kanban-heute-sync.json"
  local metadata = vim.json.decode(table.concat(read(metadata_path), "\n"))
  local ids = {}
  for id, entry in pairs(metadata) do ids[entry.parent_title] = id end
  assert(ids["Parent A"] and ids["Parent B"] and ids["Parent A"] ~= ids["Parent B"])
  assert(metadata[ids["Parent A"]].parent_id ~= metadata[ids["Parent B"]].parent_id)
  assert(read(metadata_path)[2]:match("^  "))

  -- The installed kanban.nvim Markdown reader must keep both IDs intact.
  package.path = vim.fn.stdpath("data") .. "/lazy/kanban.nvim/lua/?.lua;" .. package.path
  local reader = require("kanban.markdown.reader")
  local parsed = reader.read({ fn = { tasks = { utils = {
    create_blank_task = function() return { lines = {} } end,
  } } } }, today)
  assert(count({ parsed.lists[1].tasks[1].lines[1], parsed.lists[1].tasks[2].lines[1] }, "kanban%-next%-action:") == 2)

  move_today("kanban%-next%-action:" .. ids["Parent B"], "WIP")
  assert(count(read(project), "Next: Gleiche Handlung") == 2)
  assert(count(read(project), "^%- %[x%]") == 0)
  move_today("kanban%-next%-action:" .. ids["Parent B"], "TODO")
  assert(count(read(project), "Next: Gleiche Handlung") == 2)

  move_today("kanban%-next%-action:" .. ids["Parent A"], "DONE", project)
  local project_lines = read(project)
  assert(count(project_lines, "^%- %[x%] Gleiche Handlung") == 1)
  assert(count(project_lines, "Next: Gleiche Handlung") == 1)
  assert(count(project_lines, "^%s*Next:%s*$") == 1)
  assert(count(project_lines, "Note: behalten") == 1)
  assert(count(project_lines, "Done:") == 0)
  sync.sync_file(today)
  assert(count(read(project), "^%- %[x%] Gleiche Handlung") == 1)
  move_today("kanban%-next%-action:" .. ids["Parent A"], "TODO")
  assert(count(read(project), "^%- %[x%] Gleiche Handlung") == 1)
  move_today("kanban%-next%-action:" .. ids["Parent A"], "DONE")

  package.loaded["core.functions.kanban-heute-sync"] = nil
  sync = require("core.functions.kanban-heute-sync")
  sync.config.today_file = today
  sync.sync_file(today)
  assert(count(read(project), "^%- %[x%] Gleiche Handlung") == 1)

  project_lines = read(project)
  project_lines[assert(line_of(project_lines, "^%s*Next:%s*$"))] = "    Next: Zweite Handlung"
  write(project, project_lines)
  select_task(project, "Parent A")
  sync.add_current_task()
  assert(count(read(today), "^%- %[ %] Zweite Handlung") == 1)
  local after_second = vim.json.decode(table.concat(read(metadata_path), "\n"))
  for _, entry in pairs(after_second) do
    if entry.action == "Zweite Handlung" then
      assert(entry.parent_id == metadata[ids["Parent A"]].parent_id)
    end
  end

  project_lines = read(project)
  project_lines[assert(line_of(project_lines, "Next: Gleiche Handlung"))] = "\tNext: Manuell geändert"
  write(project, project_lines)
  move_today("kanban%-next%-action:" .. ids["Parent B"], "DONE")
  assert(count(read(project), "^%- %[x%] Gleiche Handlung") == 1)
  assert(count(read(project), "Next: Manuell geändert") == 1)

  select_task(project, "Parent A")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 4, 5, false, { "    Next: Ungespeichert" })
  local before = table.concat(read(project), "\n")
  sync.sync_file(today)
  assert(table.concat(read(project), "\n") == before)
  vim.cmd("edit!")

  -- A legacy entry without a type must retain bidirectional status sync.
  local normal = "- [ ] Normale Aufgabe"
  project_lines = read(project)
  table.insert(project_lines, assert(line_of(project_lines, "^## TODO")) + 1, normal)
  write(project, project_lines)
  select_task(project, "Normale Aufgabe")
  sync.add_current_task()
  local raw = read(metadata_path)
  local data = vim.json.decode(table.concat(raw, "\n"))
  for _, entry in pairs(data) do
    if entry.title == "Normale Aufgabe" then entry.type = nil end
  end
  write(metadata_path, vim.fn.systemlist({ "jq", "--indent", "2", "." }, vim.json.encode(data)))
  move_today("Normale Aufgabe", "WIP")
  assert(count(read(project), "^%- %[ %] Normale Aufgabe") == 1)
  assert(line_of(read(project), "Normale Aufgabe") > line_of(read(project), "^## WIP"))
  assert(table.concat(read(today), "\n"):find(table.concat(footer, "\n"), 1, true))
  assert(table.concat(read(project), "\n"):find(table.concat(footer, "\n"), 1, true))

  -- A task created directly in Today can still be assigned with <leader>km.
  local today_lines = read(today)
  table.insert(today_lines, assert(line_of(today_lines, "^## TODO")) + 1, "- [ ] Direkt in Heute")
  write(today, today_lines)
  package.loaded.kanban = { active = false }
  vim.ui.select = function(items, _, callback)
    for _, item in ipairs(items) do
      if item.path == vim.uv.fs_realpath(project) then callback(item); return end
    end
    error("Projekt im Picker fehlt")
  end
  select_task(today, "Direkt in Heute")
  sync.move_current_task()
  assert(count(read(project), "Direkt in Heute") == 1)
  sync.move_current_task()
  assert(count(read(project), "Direkt in Heute") == 1)

  -- Reset removes only today's tasks and links; project history and open Next remain.
  local project_before_reset = table.concat(read(project), "\n")
  vim.fn.confirm = function() return 1 end
  sync.reset_today()
  assert(count(read(today), "^%- %[.%]") == 0)
  assert(next(vim.json.decode(table.concat(read(metadata_path), "\n"))) == nil)
  assert(table.concat(read(project), "\n") == project_before_reset)
  assert(table.concat(read(today), "\n"):find(table.concat(footer, "\n"), 1, true))

  -- If JSON persistence fails after the project write, the next run resumes.
  local action = require("core.functions.kanban-next-action")
  local partial_project = dir .. "/kanban-ernaehrung-vortrag.md"
  local partial_today = dir .. "/kanban-partial-heute.md"
  local partial_json = dir .. "/kanban-partial-sync.json"
  local partial_id = "abc123def456"
  write(partial_project, { "## TODO", "", "- [ ] Partial Parent", "    Next: Partial Action", "", "## DONE", "", unpack(footer) })
  write(partial_today, { "## TODO", "", "## DONE", "", "- [x] Partial Action <!-- kanban-next-action:" .. partial_id .. " -->", "", unpack(footer) })
  local pending = { [partial_id] = {
    type = "next_action", source = partial_project, parent_title = "Partial Parent",
    parent_body = {}, action = "Partial Action", completed = false,
  } }
  write(partial_json, vim.fn.systemlist({ "jq", "." }, vim.json.encode(pending)))
  local saves = 0
  local ctx = {
    today = partial_today, metadata = pending,
    read_lines = read, write_lines = function(path, lines) write(path, lines); return true end,
    can_modify_file = function() return true end, reload_buffer = function() end,
    notify = function() end,
    find_task_insert_position = function(lines, section)
      return assert(line_of(lines, "^## " .. section)) + 1
    end,
    save_metadata = function(data)
      saves = saves + 1
      if saves == 1 then return false end
      write(partial_json, vim.fn.systemlist({ "jq", "." }, vim.json.encode(data)))
      return true
    end,
  }
  action.sync(partial_today, ctx)
  assert(count(read(partial_today), "Partial Action #ernaehrung%-vortrag <!%-%- kanban%-next%-action:") == 1)
  assert(count(read(partial_project), "^%- %[x%] Partial Action") == 1)
  assert(count(read(partial_project), "^%s*Next:%s*$") == 1)
  ctx.metadata = vim.json.decode(table.concat(read(partial_json), "\n"))
  assert(ctx.metadata[partial_id].completed == false)
  action.sync(partial_today, ctx)
  assert(count(read(partial_project), "^%- %[x%] Partial Action") == 1)
  assert(count(read(partial_today), "Partial Action #ernaehrung%-vortrag <!%-%- kanban%-next%-action:") == 1)
  assert(vim.json.decode(table.concat(read(partial_json), "\n"))[partial_id].completed == true)

  -- A deleted parent must never produce an orphan DONE card.
  local missing_id = "fed321abc654"
  ctx.metadata[missing_id] = {
    type = "next_action", source = partial_project, parent_title = "Deleted Parent",
    parent_body = {}, action = "Orphan Action", completed = false,
  }
  write(partial_today, { "## TODO", "", "## DONE", "", "- [x] Orphan Action <!-- kanban-next-action:" .. missing_id .. " -->", "", unpack(footer) })
  action.sync(partial_today, ctx)
  assert(count(read(partial_project), "Orphan Action") == 0)
  assert(ctx.metadata[missing_id].completed == false)

  print("kanban-next-action: alle Integrationstests bestanden")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
