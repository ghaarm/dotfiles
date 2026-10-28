local M = {}

---------------------------------------------------------------------------
-- Konfiguration
---------------------------------------------------------------------------

M.config = {
  today_file = vim.fn.expand(
    "~/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/kanban-icloud/kanban-heute.md"
  ),
}

---------------------------------------------------------------------------
-- Hilfsfunktionen
---------------------------------------------------------------------------

local function notify(message, level)
  vim.notify("Kanban Heute: " .. message, level or vim.log.levels.INFO)
end

local function normalize_path(path)
  path = vim.fn.fnamemodify(path, ":p")
  return vim.uv.fs_realpath(path) or path
end

local function read_lines(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  return vim.fn.readfile(path)
end

local function write_lines(path, lines)
  local ok, result = pcall(vim.fn.writefile, lines, path)

  if not ok or result ~= 0 then
    notify("Datei konnte nicht geschrieben werden:\n" .. path, vim.log.levels.ERROR)
    return false
  end

  return true
end

local function metadata_path()
  return M.config.today_file:gsub("%.md$", "-sync.json")
end

local function load_metadata()
  local path = metadata_path()

  if vim.fn.filereadable(path) ~= 1 then
    return {}
  end

  local ok, data = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)

  if not ok or type(data) ~= "table" then
    notify("Ungültige Sync-Metadaten.", vim.log.levels.ERROR)
    return nil
  end

  return data
end

local function save_metadata(data)
  local json = vim.json.encode(data)

  -- JSON mit jq lesbar formatieren.
  local result = vim.fn.systemlist({ "jq", "--indent", "2", "." }, json)

  if vim.v.shell_error ~= 0 then
    notify("JSON konnte nicht formatiert werden. Ist jq installiert?", vim.log.levels.ERROR)
    return false
  end

  return write_lines(metadata_path(), result)
end

---------------------------------------------------------------------------
-- Kanban-Spalten
---------------------------------------------------------------------------

local function get_section(list_name)
  local title = vim.trim(list_name):upper()

  if title:match("^DONE") then
    return "DONE"
  end

  if title:match("^WIP") then
    return "WIP"
  end

  if title:match("^TODO") then
    return "TODO"
  end

  return nil
end

local function find_section(lines, section)
  for i, line in ipairs(lines) do
    local title = line:match("^##%s+(.+)$")

    if title and get_section(title) == section then
      return i
    end
  end

  return nil
end
---------------------------------------------------------------------------
-- Einfügeposition innerhalb einer Kanban-Spalte bestimmen
---------------------------------------------------------------------------

local function find_task_insert_position(lines, section)
  local section_line = find_section(lines, section)

  if not section_line then
    return nil
  end

  local section_end = #lines + 1

  for i = section_line + 1, #lines do
    if lines[i]:match("^##%s+") or lines[i]:match("^#%s+") or lines[i]:match("^%%%% kanban:settings") then
      section_end = i
      break
    end
  end

  local last_content = section_line

  for i = section_line + 1, section_end - 1 do
    if vim.trim(lines[i]) ~= "" then
      last_content = i
    end
  end

  return last_content + 1
end
---------------------------------------------------------------------------
-- Aufgabe aus Markdown ermitteln
---------------------------------------------------------------------------

local function get_markdown_task()
  local bufnr = vim.api.nvim_get_current_buf()
  local source = vim.api.nvim_buf_get_name(bufnr)

  if source == "" or not source:match("%.md$") then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Anfang der Aufgabe suchen.
  local task_start = nil

  for i = cursor_line, 1, -1 do
    if lines[i]:match("^%- %[.%] ") then
      task_start = i
      break
    end

    -- Nicht über eine Abschnittsüberschrift hinaus suchen.
    if lines[i]:match("^##%s+") then
      break
    end
  end

  if not task_start then
    notify("Cursor steht auf keiner Kanban-Aufgabe.", vim.log.levels.WARN)
    return nil
  end

  -- Zugehörige Spalte ermitteln.
  local list_name = nil

  for i = task_start, 1, -1 do
    local title = lines[i]:match("^##%s+(.+)$")

    if title then
      list_name = title
      break
    end
  end

  if not list_name then
    notify("Keine Kanban-Spalte gefunden.", vim.log.levels.WARN)
    return nil
  end

  -- Ende der Aufgabe suchen.
  local task_end = task_start

  for i = task_start + 1, #lines do
    local line = lines[i]

    if line:match("^%- %[.%] ") or line:match("^##%s+") or line:match("^#%s+") then
      break
    end

    task_end = i
  end

  -- Leerzeilen am Ende entfernen.
  while task_end > task_start and vim.trim(lines[task_end]) == "" do
    task_end = task_end - 1
  end

  local first_line = lines[task_start]

  local checked = first_line:match("^%- %[xX%] ") ~= nil

  local title = first_line:match("^%- %[.%] (.*)$")

  if not title or vim.trim(title) == "" then
    notify("Leere Aufgabe.", vim.log.levels.WARN)
    return nil
  end

  local task_lines = { title }

  for i = task_start + 1, task_end do
    local line = lines[i]

    -- Eine Ebene Markdown-Einrückung entfernen.
    line = line:gsub("^\t", "", 1)
    line = line:gsub("^    ", "", 1)

    table.insert(task_lines, line)
  end

  return {
    source = normalize_path(source),
    list_name = list_name,
    lines = task_lines,
    check = checked,
    position = task_start,
  }
end

---------------------------------------------------------------------------
-- Aufgabe aus grafischem Kanban-Board ermitteln
---------------------------------------------------------------------------

local function get_board_task()
  local ok, k = pcall(require, "kanban")

  if not ok or not k.active then
    return nil
  end

  local focus_ok, focus = pcall(k.fn.tasks.utils.get_focus, k)

  if not focus_ok or not focus then
    return nil
  end

  local list = k.items.lists[focus.list_num]
  local task = list and list.tasks[focus.task_num]

  if not task then
    return nil
  end

  local task_lines = task.lines

  if task.buf_nr and vim.api.nvim_buf_is_valid(task.buf_nr) then
    task_lines = vim.api.nvim_buf_get_lines(task.buf_nr, 0, -1, false)
  end

  return {
    source = normalize_path(k.kanban_md_path),
    list_name = list.title,
    lines = vim.deepcopy(task_lines),
    check = task.check,
  }
end

---------------------------------------------------------------------------
-- Aktuelle Aufgabe ermitteln
---------------------------------------------------------------------------

local function get_current_task()
  -- Zuerst normale Markdown-Datei prüfen.
  local task = get_markdown_task()

  if task then
    return task
  end

  -- Anschließend grafisches Kanban-Board prüfen.
  task = get_board_task()

  if task then
    return task
  end

  notify("Keine Kanban-Aufgabe gefunden.", vim.log.levels.WARN)

  return nil
end

---------------------------------------------------------------------------
-- Aufgabenidentität
---------------------------------------------------------------------------

local function task_key(task)
  return table.concat({
    task.source,
    task.list_name,
    table.concat(task.lines, "\n"),
  }, "\n")
end

---------------------------------------------------------------------------
-- Aufgabe nach Heute übernehmen
---------------------------------------------------------------------------

function M.add_current_task()
  local task = get_current_task()

  if not task then
    return
  end

  local today = normalize_path(M.config.today_file)

  if task.source == today then
    notify("Aufgabe befindet sich bereits im Tages-Kanban.")
    return
  end

  if vim.fn.filereadable(today) ~= 1 then
    notify("Tages-Kanban existiert nicht:\n" .. today, vim.log.levels.ERROR)
    return
  end

  local section = get_section(task.list_name)

  if not section then
    notify("Unbekannte Kanban-Spalte: " .. task.list_name, vim.log.levels.ERROR)
    return
  end

  -- Verhindern, dass eine extern geänderte Datei einen
  -- bereits geöffneten, ungespeicherten Buffer überschreibt.
  local today_bufnr = vim.fn.bufnr(today)

  if today_bufnr ~= -1 and vim.api.nvim_buf_is_loaded(today_bufnr) and vim.bo[today_bufnr].modified then
    notify("Tages-Kanban enthält ungespeicherte Änderungen. Bitte zuerst speichern.", vim.log.levels.WARN)
    return
  end

  local metadata = load_metadata()

  if not metadata then
    return
  end

  local key = task_key(task)

  for _, entry in pairs(metadata) do
    if entry.key == key then
      notify("Aufgabe wurde bereits übernommen.")
      return
    end
  end

  local lines = read_lines(today)

  if not lines then
    notify("Tages-Kanban konnte nicht gelesen werden.", vim.log.levels.ERROR)
    return
  end

  local section_line = find_section(lines, section)

  if not section_line then
    notify("Zielspalte " .. section .. " nicht gefunden.", vim.log.levels.ERROR)
    return
  end

  -- Ende der Zielspalte bestimmen.
  local insert_at = #lines + 1

  for i = section_line + 1, #lines do
    if lines[i]:match("^##%s+") or lines[i]:match("^#%s+") or lines[i]:match("^%%%% kanban:settings") then
      insert_at = i
      break
    end
  end

  -- Neue Markdown-Aufgabe erstellen.
  local new_lines = {
    (task.check and "- [x] " or "- [ ] ") .. task.lines[1],
  }

  for i = 2, #task.lines do
    table.insert(new_lines, "\t" .. task.lines[i])
  end

  table.insert(new_lines, "")

  -- Aufgabe in die passende Spalte einfügen.
  for i = #new_lines, 1, -1 do
    table.insert(lines, insert_at, new_lines[i])
  end

  if not write_lines(today, lines) then
    return
  end

  -- Herkunft dokumentieren.
  local id = os.date("%Y%m%d-%H%M%S") .. "-" .. tostring(math.random(1000, 9999))

  metadata[id] = {
    key = key,
    source = task.source,
    source_list = task.list_name,
    title = task.lines[1],
    position = task.position,
  }

  if not save_metadata(metadata) then
    notify("Aufgabe übernommen, aber Sync-Metadaten konnten nicht gespeichert werden.", vim.log.levels.ERROR)
    return
  end

  -- Bereits geladenen, unveränderten Tages-Buffer aktualisieren.
  if today_bufnr ~= -1 and vim.api.nvim_buf_is_loaded(today_bufnr) then
    vim.api.nvim_buf_call(today_bufnr, function()
      vim.cmd("edit!")
    end)
  end

  notify("Aufgabe nach Heute übernommen: " .. task.lines[1])
end
---------------------------------------------------------------------------
-- Automatische bidirektionale Status-Synchronisierung
---------------------------------------------------------------------------

local sync_running = false

---------------------------------------------------------------------------
-- Aufgaben und ihre Positionen aus Markdown lesen
---------------------------------------------------------------------------

local function parse_tasks(lines)
  local tasks = {}
  local section = nil
  local footer_start = #lines + 1

  for i, line in ipairs(lines) do
    -- Kanban-Metadaten gehören nicht zu den Aufgaben.
    if line:match("^%%%% kanban:settings") then
      footer_start = i
      break
    end

    local heading = line:match("^##%s+(.+)$")

    if heading then
      section = get_section(heading)
    end

    local checked, title = line:match("^%- %[([ xX])%] (.*)$")

    if checked and section then
      table.insert(tasks, {
        title = title,
        section = section,
        start_line = i,
        check = checked:lower() == "x",
      })
    end
  end

  for index, task in ipairs(tasks) do
    local next_task = tasks[index + 1]

    local last_line = next_task and (next_task.start_line - 1) or (footer_start - 1)

    for i = task.start_line + 1, last_line do
      if lines[i]:match("^##%s+") or lines[i]:match("^#%s+") then
        last_line = i - 1
        break
      end
    end

    while last_line > task.start_line and vim.trim(lines[last_line]) == "" do
      last_line = last_line - 1
    end

    task.end_line = last_line
  end

  return tasks
end

---------------------------------------------------------------------------
-- Aufgabe eindeutig anhand des Titels finden
---------------------------------------------------------------------------

local function find_unique_task(tasks, title)
  local found = nil

  for _, task in ipairs(tasks) do
    if task.title == title then
      if found then
        return nil, "duplicate"
      end

      found = task
    end
  end

  return found
end

---------------------------------------------------------------------------
-- Aufgabe zwischen Kanban-Spalten verschieben
---------------------------------------------------------------------------

local function move_task(lines, task, target_section)
  if task.section == target_section then
    return lines
  end

  -- Zielspalte prüfen, bevor Änderungen vorgenommen werden.
  if not find_section(lines, target_section) then
    return nil
  end

  -- Aufgabeninhalt übernehmen.
  local task_lines = {}

  for i = task.start_line, task.end_line do
    table.insert(task_lines, lines[i])
  end

  -- Checkbox an die Zielspalte anpassen.
  task_lines[1] = task_lines[1]:gsub("^%- %[[ xX]%]", target_section == "DONE" and "- [x]" or "- [ ]")

  -- Aufgabe aus der bisherigen Spalte entfernen.
  for i = task.end_line, task.start_line, -1 do
    table.remove(lines, i)
  end

  -- Überflüssige Leerzeilen an der alten Position entfernen.
  -- Maximal zwei aufeinanderfolgende Leerzeilen beibehalten.
  local function normalize_blank_lines()
    local i = 1
    local blanks = 0

    while i <= #lines do
      if vim.trim(lines[i]) == "" then
        blanks = blanks + 1

        if blanks > 2 then
          table.remove(lines, i)
        else
          i = i + 1
        end
      else
        blanks = 0
        i = i + 1
      end
    end
  end

  normalize_blank_lines()

  -- Zielspalte erneut bestimmen.
  local section_line = find_section(lines, target_section)

  -- Ende der Zielspalte suchen.
  local section_end = #lines + 1

  for i = section_line + 1, #lines do
    if lines[i]:match("^##%s+") or lines[i]:match("^#%s+") or lines[i]:match("^%%%% kanban:settings") then
      section_end = i
      break
    end
  end

  -- Letzte nichtleere Zeile innerhalb der Zielspalte suchen.
  local last_content = section_line

  for i = section_line + 1, section_end - 1 do
    if vim.trim(lines[i]) ~= "" then
      last_content = i
    end
  end

  -- Neue Aufgabe direkt hinter dem letzten Inhalt einfügen.
  local insert_at = last_content + 1

  -- Eine Leerzeile vor der Aufgabe.
  local new_lines = { "" }

  vim.list_extend(new_lines, task_lines)

  for i = #new_lines, 1, -1 do
    table.insert(lines, insert_at, new_lines[i])
  end

  -- Auch nach dem Einfügen überflüssige Leerzeilen entfernen.
  normalize_blank_lines()

  return lines
end

---------------------------------------------------------------------------
-- Ungespeicherte Änderungen schützen
---------------------------------------------------------------------------

local function can_modify_file(path)
  local bufnr = vim.fn.bufnr(path)

  if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
    notify(
      "Synchronisierung übersprungen: Ungespeicherte Änderungen in " .. vim.fn.fnamemodify(path, ":t"),
      vim.log.levels.WARN
    )

    return false
  end

  return true
end

---------------------------------------------------------------------------
-- Geöffneten Buffer nach externer Änderung aktualisieren
---------------------------------------------------------------------------

local function reload_buffer(path)
  local bufnr = vim.fn.bufnr(path)

  if bufnr == -1 or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  if vim.bo[bufnr].modified then
    return
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("silent! edit!")
  end)
end

---------------------------------------------------------------------------
-- Status zwischen Projekt-Kanban und Tages-Kanban synchronisieren
---------------------------------------------------------------------------

function M.sync_file(changed_path)
  if sync_running or not changed_path or changed_path == "" then
    return
  end

  local changed = normalize_path(changed_path)
  local today = normalize_path(M.config.today_file)

  local metadata = load_metadata()

  if not metadata then
    return
  end

  -- Nur Dateien synchronisieren, die tatsächlich beteiligt sind.
  local relevant = changed == today

  if not relevant then
    for _, entry in pairs(metadata) do
      if entry.source and normalize_path(entry.source) == changed then
        relevant = true
        break
      end
    end
  end

  if not relevant then
    return
  end

  local changed_lines = read_lines(changed)

  if not changed_lines then
    return
  end

  local changed_tasks = parse_tasks(changed_lines)

  -- Verknüpfungen entfernen, deren Aufgabe im Projekt gelöscht wurde.
  -- Nur prüfen, wenn tatsächlich ein Projekt-Kanban gespeichert wurde.
  if changed ~= today then
    local metadata_changed = false

    for id, entry in pairs(metadata) do
      if entry.source and normalize_path(entry.source) == changed then
        local existing, err = find_unique_task(changed_tasks, entry.title)

        if not existing and err ~= "duplicate" then
          metadata[id] = nil
          metadata_changed = true

          notify("Verknüpfung entfernt: " .. entry.title)
        end
      end
    end

    if metadata_changed and not save_metadata(metadata) then
      return
    end
  end

  sync_running = true

  local ok, err = pcall(function()
    for _, entry in pairs(metadata) do
      if entry.source and entry.title then
        local source = normalize_path(entry.source)

        if changed == today or changed == source then
          -- Synchronisierungsrichtung bestimmen.
          local target = changed == today and source or today

          if vim.fn.filereadable(target) == 1 then
            local target_lines = read_lines(target)

            if target_lines then
              local target_tasks = parse_tasks(target_lines)

              local current_task, current_error = find_unique_task(changed_tasks, entry.title)

              local target_task, target_error = find_unique_task(target_tasks, entry.title)

              if current_error == "duplicate" or target_error == "duplicate" then
                notify("Mehrdeutige Aufgabe, nicht synchronisiert: " .. entry.title, vim.log.levels.WARN)
              elseif current_task and target_task then
                if current_task.section ~= target_task.section then
                  if can_modify_file(target) then
                    local new_lines = move_task(target_lines, target_task, current_task.section)

                    if new_lines and write_lines(target, new_lines) then
                      reload_buffer(target)

                      notify("Synchronisiert: " .. entry.title .. " → " .. current_task.section)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end)

  sync_running = false

  if not ok then
    notify("Fehler bei der Synchronisierung:\n" .. tostring(err), vim.log.levels.ERROR)
  end
end
---------------------------------------------------------------------------
-- Heute-Aufgabe einem Projekt-Kanban zuordnen
---------------------------------------------------------------------------

function M.move_current_task()
  local kanban = require("kanban")
  local today = normalize_path(M.config.today_file)

  -- Bei aktivem grafischem Board zuerst die dortige Aufgabe ermitteln.
  local task

  if kanban.active then
    task = get_board_task()
  else
    task = get_markdown_task()
  end

  if not task then
    notify("Keine Kanban-Aufgabe ausgewählt.", vim.log.levels.WARN)
    return
  end

  if task.source ~= today then
    notify("Diese Funktion ist nur im Tages-Kanban verfügbar.", vim.log.levels.WARN)
    return
  end

  local section = get_section(task.list_name)

  if not section then
    notify("Unbekannte Kanban-Spalte.", vim.log.levels.ERROR)
    return
  end

  local title = task.lines[1]

  if not title or vim.trim(title) == "" then
    notify("Aufgabe hat keinen Titel.", vim.log.levels.WARN)
    return
  end

  -- Grafisches Board vor der weiteren Verarbeitung speichern.
  if kanban.active then
    local ok, err = pcall(vim.cmd, "KanbanSave")

    if not ok then
      notify("Tages-Kanban konnte nicht gespeichert werden:\n" .. tostring(err), vim.log.levels.ERROR)
      return
    end
  else
    local bufnr = vim.api.nvim_get_current_buf()

    if vim.bo[bufnr].modified then
      local ok, err = pcall(vim.cmd, "write")

      if not ok then
        notify("Tages-Kanban konnte nicht gespeichert werden:\n" .. tostring(err), vim.log.levels.ERROR)
        return
      end
    end
  end

  local metadata = load_metadata()

  if not metadata then
    return
  end

  -- Bereits zugeordnete Aufgaben erkennen.
  -- Veraltete Zuordnungen automatisch entfernen.

  local metadata_changed = false

  for id, entry in pairs(metadata) do
    if entry.title == title then
      local source = entry.source and normalize_path(entry.source)
      local source_lines = source and read_lines(source)

      if not source_lines then
        notify("Projektdatei nicht erreichbar. Zuordnung bleibt bestehen.", vim.log.levels.WARN)
        return
      end

      local source_tasks = parse_tasks(source_lines)
      local existing, err = find_unique_task(source_tasks, title)

      if err == "duplicate" then
        notify("Aufgabe ist im Projekt mehrfach vorhanden. Zuordnung bleibt bestehen.", vim.log.levels.WARN)
        return
      end

      if existing then
        notify(
          "Aufgabe ist bereits einem Projekt zugeordnet:\n" .. vim.fn.fnamemodify(source, ":t"),
          vim.log.levels.WARN
        )
        return
      end

      -- Aufgabe wurde im Projekt gelöscht:
      -- veraltete Verknüpfung entfernen.
      metadata[id] = nil
      metadata_changed = true
    end
  end

  if metadata_changed then
    if not save_metadata(metadata) then
      return
    end
  end

  -- Mehrdeutige Aufgabentitel im Tages-Kanban verhindern.
  local today_lines = read_lines(today)

  if not today_lines then
    notify("Tages-Kanban konnte nicht gelesen werden.", vim.log.levels.ERROR)
    return
  end

  local today_tasks = parse_tasks(today_lines)
  local _, duplicate_error = find_unique_task(today_tasks, title)

  if duplicate_error == "duplicate" then
    notify("Aufgabentitel ist im Tages-Kanban nicht eindeutig.", vim.log.levels.WARN)
    return
  end

  -------------------------------------------------------------------------
  -- Verfügbare Projekt-Kanbans ermitteln
  -------------------------------------------------------------------------

  local directory = vim.fn.fnamemodify(M.config.today_file, ":h")

  local files = vim.fn.globpath(directory, "kanban-*.md", false, true)

  local projects = {}
  local seen = {}

  for _, file in ipairs(files) do
    local path = normalize_path(file)

    if path ~= today and not seen[path] then
      seen[path] = true

      table.insert(projects, {
        name = vim.fn.fnamemodify(file, ":t"),
        path = path,
      })
    end
  end

  table.sort(projects, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  if #projects == 0 then
    notify("Keine Projekt-Kanbans gefunden.", vim.log.levels.WARN)
    return
  end

  -------------------------------------------------------------------------
  -- Projekt auswählen
  -------------------------------------------------------------------------

  vim.ui.select(projects, {
    prompt = "Aufgabe in Projekt übernehmen:",

    format_item = function(item)
      return item.name:gsub("^kanban%-", ""):gsub("%.md$", "")
    end,
  }, function(selection)
    if not selection then
      return
    end

    local target = selection.path

    if not can_modify_file(target) then
      return
    end

    local lines = read_lines(target)

    if not lines then
      notify("Projekt-Kanban konnte nicht gelesen werden.", vim.log.levels.ERROR)
      return
    end

    local existing_tasks = parse_tasks(lines)
    local existing = find_unique_task(existing_tasks, title)

    if existing then
      notify("Aufgabe existiert bereits im Zielprojekt.", vim.log.levels.WARN)
      return
    end

    local insert_at = find_task_insert_position(lines, section)

    if not insert_at then
      notify("Zielspalte " .. section .. " nicht gefunden.", vim.log.levels.ERROR)
      return
    end

    -----------------------------------------------------------------------
    -- Aufgabe im Projekt-Kanban erstellen
    -----------------------------------------------------------------------

    local new_lines = {
      "",
      (section == "DONE" and "- [x] " or "- [ ] ") .. title,
    }

    for i = 2, #task.lines do
      table.insert(new_lines, "\t" .. task.lines[i])
    end

    for i = #new_lines, 1, -1 do
      table.insert(lines, insert_at, new_lines[i])
    end

    if not write_lines(target, lines) then
      return
    end

    -----------------------------------------------------------------------
    -- Synchronisierungsverknüpfung erstellen
    -----------------------------------------------------------------------

    -- Herkunft dokumentieren.
    local id = os.date("%Y%m%d-%H%M%S") .. "-" .. tostring(math.random(1000, 9999))

    metadata[id] = {
      key = task_key({
        source = target,
        list_name = task.list_name,
        lines = task.lines,
      }),

      source = target,
      source_list = task.list_name,
      title = title,
    }

    if not save_metadata(metadata) then
      notify(
        "Aufgabe wurde ins Projekt übernommen, aber die Synchronisierung konnte nicht eingerichtet werden.",
        vim.log.levels.ERROR
      )
      return
    end

    reload_buffer(target)

    notify("Aufgabe zugeordnet: " .. title .. " → " .. selection.name)
  end)
end

---------------------------------------------------------------------------
-- Tages-Kanban zurücksetzen
---------------------------------------------------------------------------

function M.reset_today()
  local kanban = require("kanban")
  local today = normalize_path(M.config.today_file)

  -- Verhindern, dass ein noch geöffnetes grafisches Board
  -- später den zurückgesetzten Inhalt überschreibt.
  if kanban.active and normalize_path(kanban.kanban_md_path or "") == today then
    notify("Bitte zuerst das grafische Tages-Kanban schließen.", vim.log.levels.WARN)
    return
  end

  if not can_modify_file(today) then
    return
  end

  local confirmation = vim.fn.confirm(
    "Tages-Kanban wirklich zurücksetzen?\n\n"
      .. "Alle Aufgaben werden aus Heute entfernt.\n"
      .. "Die Projekt-Kanbans bleiben unverändert.",
    "&Zurücksetzen\n&Abbrechen",
    2
  )

  if confirmation ~= 1 then
    return
  end

  local lines = read_lines(today)

  if not lines then
    notify("Tages-Kanban konnte nicht gelesen werden.", vim.log.levels.ERROR)
    return
  end

  -------------------------------------------------------------------------
  -- Header und Footer erhalten
  -------------------------------------------------------------------------

  local first_section = nil
  local footer_start = nil

  for i, line in ipairs(lines) do
    if not first_section and line:match("^##%s+") then
      first_section = i
    end

    if line:match("^%%%% kanban:settings") then
      footer_start = i
      break
    end
  end

  if not first_section or not footer_start then
    notify("Kanban-Struktur unvollständig. Reset abgebrochen.", vim.log.levels.ERROR)
    return
  end

  local new_lines = {}

  -- Bestehenden Header übernehmen.
  for i = 1, first_section - 1 do
    table.insert(new_lines, lines[i])
  end

  -- Leere Standardspalten erstellen.
  vim.list_extend(new_lines, {
    "## TODO",
    "",
    "## WIP (max. 3)",
    "",
    "## DONE",
    "",
    "",
  })

  -- Bestehenden Footer übernehmen.
  for i = footer_start, #lines do
    table.insert(new_lines, lines[i])
  end

  -------------------------------------------------------------------------
  -- Tages-Kanban und Metadaten zurücksetzen
  -------------------------------------------------------------------------

  if not write_lines(today, new_lines) then
    return
  end

  if not save_metadata({}) then
    notify(
      "Tages-Kanban wurde geleert, aber die Sync-Metadaten konnten nicht zurückgesetzt werden.",
      vim.log.levels.ERROR
    )
    return
  end

  reload_buffer(today)

  notify("Tages-Kanban wurde zurückgesetzt.")
end ---------------------------------------------------------------------------
-- Tastenkürzel und automatische Synchronisierung
---------------------------------------------------------------------------
---

function M.setup()
  vim.keymap.set("n", "<leader>kh", function()
    M.add_current_task()
  end, {
    desc = "Kanban: Aufgabe nach Heute übernehmen",
    silent = true,
  })

  vim.keymap.set("n", "<leader>km", function()
    M.move_current_task()
  end, {
    desc = "Kanban: Heute-Aufgabe einem Projekt zuordnen",
    silent = true,
  })

  vim.keymap.set("n", "<leader>kr", function()
    M.reset_today()
  end, {
    desc = "Kanban: Heute zurücksetzen",
    silent = true,
  })

  local group = vim.api.nvim_create_augroup("KanbanHeuteSync", {
    clear = true,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.md",

    callback = function(args)
      M.sync_file(vim.api.nvim_buf_get_name(args.buf))
    end,
  })
end

return M
