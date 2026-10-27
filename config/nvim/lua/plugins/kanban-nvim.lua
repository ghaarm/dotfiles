-- https://github.com/arakkkkk/kanban.nvim
--
-- kanban.nvim can provide in-buffer completion for due dates (@...) and tags (#...)
-- via optional completion engines. The plugin works without any of these;
-- install only if you want completion.
--
-- What gets completed
--
-- @ due tokens are expanded to dates:
-- @today, @2d, @1w, @2m, @1y, @/MM/DD, @//DD,
-- weekdays @su..@sa, and next-week variants like @nmo, @nwe, etc.
--
-- # tags are suggested from existing task tags found in the current Kanban board
-- (unique, case-insensitive match).

---------------------------------------------------------------------------
-- Symlink für neue Kanban-Boards im zentralen iCloud-Verzeichnis erstellen
---------------------------------------------------------------------------

local function create_icloud_symlink(file)
  local icloud_dir = "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/kanban-icloud"

  -- Prüfen, ob das iCloud-Verzeichnis existiert.
  if vim.fn.isdirectory(icloud_dir) ~= 1 then
    vim.notify("Kanban-iCloud-Verzeichnis existiert nicht:\n" .. icloud_dir, vim.log.levels.ERROR)
    return
  end

  -- Absoluten Pfad zur Originaldatei ermitteln.
  local source = vim.fn.fnamemodify(file, ":p")

  -- Symlink mit demselben Dateinamen im iCloud-Verzeichnis erstellen.
  local link = vim.fs.joinpath(icloud_dir, vim.fn.fnamemodify(file, ":t"))

  -- Existierende Dateien und Symlinks nicht überschreiben.
  -- getftype erkennt auch defekte Symlinks.
  if vim.fn.getftype(link) ~= "" then
    vim.notify("Kanban-iCloud-Link existiert bereits:\n" .. link, vim.log.levels.WARN)
    return
  end

  -- Symbolischen Link erstellen.
  local result = vim.fn.system({
    "ln",
    "-s",
    source,
    link,
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("Kanban-iCloud-Symlink konnte nicht erstellt werden:\n" .. result, vim.log.levels.ERROR)
    return
  end

  vim.notify("Kanban-iCloud-Symlink erstellt:\n" .. link, vim.log.levels.INFO)
end

return {
  "arakkkkk/kanban.nvim",

  dependencies = {
    "nvim-telescope/telescope.nvim",
  },

  opts = {
    move_position = "top",
    add_position = "bottom",

    layout = {
      task_height = 3,
      task_y_margin = 2,
    },

    markdown = {
      description_folder = "./tasks/",
      -- list_head = "## ",
      due_format = "YYYY-MM-DD",

      default_lists = {
        "TODO",
        "WIP (max. 3)",
        "DONE",
      },
    },
  },

  config = function(_, opts)
    local kanban = require("kanban")

    kanban.setup(opts)

    ---------------------------------------------------------------------------
    -- Dynamische Kartenhöhe
    -- Karten wachsen mit dem Inhalt, maximal 20 Zeilen.
    -- Bei Platzmangel bleibt der Inhalt innerhalb der Karte scrollbar.
    ---------------------------------------------------------------------------

    local min_task_height = 1
    local max_task_height = 20

    ---------------------------------------------------------------------------
    -- Benötigte Höhe anhand des Inhalts berechnen
    ---------------------------------------------------------------------------

    local function get_task_height(task, list)
      local lines = task.lines or {}

      -- Aktuellen Bufferinhalt verwenden.
      if task.buf_nr and vim.api.nvim_buf_is_valid(task.buf_nr) then
        lines = vim.api.nvim_buf_get_lines(task.buf_nr, 0, -1, false)
      end

      -- Tatsächliche Breite des Karteninhalts.
      local width = math.max(1, list.buf_conf.width - 4)

      local total_height = 0

      for _, line in ipairs(lines) do
        local display_width = vim.fn.strdisplaywidth(line)

        total_height = total_height + math.max(1, math.ceil(display_width / width))
      end

      return math.max(min_task_height, math.min(total_height, max_task_height))
    end

    ---------------------------------------------------------------------------
    -- Karten innerhalb der Spalte positionieren
    ---------------------------------------------------------------------------

    local function resize_tasks(k, _)
      for _, list in ipairs(k.items.lists) do
        local row = list.buf_conf.row + 4

        -- Unteren Rand der Spalte berücksichtigen.
        local bottom = list.buf_conf.row + list.buf_conf.height - 1

        for _, task in ipairs(list.tasks) do
          if task.win_id and vim.api.nvim_win_is_valid(task.win_id) then
            local desired_height = get_task_height(task, list)

            -- Verbleibenden Platz innerhalb der Spalte berechnen.
            local available_height = bottom - row - 1

            if available_height >= min_task_height then
              local height = math.min(desired_height, available_height)

              task.buf_conf.width = list.buf_conf.width - 4
              task.buf_conf.height = height
              task.buf_conf.row = row
              task.buf_conf.col = list.buf_conf.col + 2

              vim.api.nvim_win_set_config(task.win_id, task.buf_conf)

              vim.wo[task.win_id].wrap = true
              vim.wo[task.win_id].linebreak = true
              vim.wo[task.win_id].breakindent = false

              -- Innerhalb der Karte kann gescrollt werden.
              vim.wo[task.win_id].scrolloff = 0

              -- Platz für Kartenhöhe, Rahmen und Abstand.
              row = row + height + k.ops.layout.task_y_margin + 2
            end
          end
        end
      end
    end

    require("kanban.fn.tasks.resize").resize = resize_tasks
    kanban.fn.tasks.resize = resize_tasks

    ---------------------------------------------------------------------------
    -- Karten bereits beim Öffnen richtig dimensionieren
    ---------------------------------------------------------------------------

    local original_task_open = kanban.fn.tasks.open

    kanban.fn.tasks.open = function(k, task)
      for _, list in ipairs(k.items.lists) do
        for _, candidate in ipairs(list.tasks) do
          if candidate == task then
            task.buf_conf.height = math.min(get_task_height(task, list), math.max(1, list.buf_conf.height - 6))
            break
          end
        end
      end

      return original_task_open(k, task)
    end

    ---------------------------------------------------------------------------
    -- Kartenhöhe während der Bearbeitung aktualisieren
    ---------------------------------------------------------------------------

    local original_task_autocmd = kanban.fn.tasks.autocmd

    kanban.fn.tasks.autocmd = function(k, task)
      -- Originale Autocommands beibehalten.
      original_task_autocmd(k, task)

      -- Zusätzlich die Fensterhöhe bei Textänderungen aktualisieren.
      vim.api.nvim_create_autocmd({
        "TextChanged",
        "TextChangedI",
        "TextChangedP",
      }, {
        buffer = task.buf_nr,

        callback = function()
          if k.active then
            resize_tasks(k, 0)
          end
        end,
      })
    end

    ---------------------------------------------------------------------------
    -- Kanban-Markdown automatisch speichern
    ---------------------------------------------------------------------------

    -- Kanban-Markdown beim Verlassen des Insert-Modus ohne Rückfrage schreiben.
    -- auto-save.nvim speichert erst verzögert und verwendet :write ohne !.
    local autosave_group = vim.api.nvim_create_augroup("KanbanMarkdownAutosave", { clear = true })

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = autosave_group,
      pattern = "*.md",

      callback = function(event)
        local buf = event.buf

        if not vim.bo[buf].modified or vim.bo[buf].buftype ~= "" then
          return
        end

        local header = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 6, false), "\n")

        if not header:find("kanban-plugin: basic", 1, true) then
          return
        end

        vim.api.nvim_buf_call(buf, function()
          local ok, err = pcall(vim.cmd, "silent write!")

          if not ok then
            vim.notify("Kanban-Datei konnte nicht gespeichert werden: " .. err, vim.log.levels.ERROR)
          end
        end)
      end,
    })

    ---------------------------------------------------------------------------
    -- Prüfen, ob eine Karte Inhalt enthält
    ---------------------------------------------------------------------------

    local function task_has_content(task)
      for _, line in ipairs(task.lines) do
        if not line:match("^%s*$") then
          return true
        end
      end

      return false
    end

    ---------------------------------------------------------------------------
    -- Leere Spalten ohne Platzhalter-Karten anzeigen
    ---------------------------------------------------------------------------

    local original_save = kanban.fn.tasks.save

    kanban.fn.tasks.save = function(k)
      local has_focus = pcall(k.fn.tasks.utils.get_focus, k)

      if has_focus then
        original_save(k)
      end
    end

    local original_add = kanban.fn.tasks.add

    kanban.fn.tasks.add = function(k, list_num, task, position, open)
      if not list_num then
        for i, list in ipairs(k.items.lists) do
          if list.win_id == vim.api.nvim_get_current_win() then
            list_num = i
            break
          end
        end
      end

      return original_add(k, list_num, task, position, open)
    end

    local function focus_list(k, list_num)
      local list = k.items.lists[list_num]

      if not list then
        return
      end

      for _, task in ipairs(list.tasks or {}) do
        if type(task.win_id) == "number" and vim.api.nvim_win_is_valid(task.win_id) then
          vim.api.nvim_set_current_win(task.win_id)
          return
        end
      end

      if type(list.win_id) == "number" and vim.api.nvim_win_is_valid(list.win_id) then
        vim.api.nvim_set_current_win(list.win_id)
      end
    end

    local function list_number(k, buf)
      for i, list in ipairs(k.items.lists) do
        if list.buf_nr == buf then
          return i
        end
      end
    end

    local original_list_add = kanban.fn.lists.add

    kanban.fn.lists.add = function(k, title)
      original_list_add(k, title, false)

      local buf = k.items.lists[#k.items.lists].buf_nr

      vim.keymap.set("n", "<C-o>", "<cmd>KanbanTaskAdd<cr>", { buffer = buf, silent = true })

      for key, step in pairs({
        ["<C-h>"] = -1,
        ["<C-l>"] = 1,
      }) do
        vim.keymap.set("n", key, function()
          local current = list_number(k, buf)

          if current then
            focus_list(k, current + step)
          end
        end, {
          buffer = buf,
          silent = true,
        })
      end
    end

    local function remove_blank_cards(k, list)
      for i = #list.tasks, 1, -1 do
        local task = list.tasks[i]

        if not task_has_content(task) then
          k.fn.tasks.close(task)
          table.remove(list.tasks, i)
        end
      end
    end

    ---------------------------------------------------------------------------
    -- Kanban-Board öffnen und leere Platzhalter entfernen
    ---------------------------------------------------------------------------

    local original_open = kanban.kanban_open

    kanban.kanban_open = function(path)
      local ok, err = pcall(original_open, path)

      if not ok then
        kanban.active = false

        vim.notify("Kanban konnte nicht geöffnet werden:\n" .. tostring(err), vim.log.levels.ERROR)

        return
      end

      if not kanban.active or not kanban.items or not kanban.items.lists then
        return
      end

      for _, list in ipairs(kanban.items.lists) do
        remove_blank_cards(kanban, list)
      end

      focus_list(kanban, 1)
    end

    ---------------------------------------------------------------------------
    -- Leere Platzhalter nach dem Löschen entfernen
    ---------------------------------------------------------------------------

    local original_delete = kanban.fn.tasks.delete

    kanban.fn.tasks.delete = function(k)
      local focus = k.fn.tasks.utils.get_focus(k)

      original_delete(k)

      local list = k.items.lists[focus.list_num]

      if #list.tasks == 1 and not task_has_content(list.tasks[1]) then
        vim.api.nvim_set_current_win(list.win_id)
        remove_blank_cards(k, list)
      end
    end

    ---------------------------------------------------------------------------
    -- Navigation in leere Spalten ermöglichen
    ---------------------------------------------------------------------------

    for _, direction in ipairs({ "left", "right" }) do
      local step = direction == "left" and -1 or 1
      local original_move = kanban.fn.tasks.move[direction]

      kanban.fn.tasks.move[direction] = function(k)
        local focus = k.fn.tasks.utils.get_focus(k)
        local target = k.items.lists[focus.list_num + step]

        if target and #target.tasks == 0 then
          k.fn.tasks.save(k)
          vim.api.nvim_set_current_win(target.win_id)
        else
          original_move(k)
        end
      end
    end

    ---------------------------------------------------------------------------
    -- Markdown: leere Platzhalter auslassen und Tasks mit Leerzeile trennen
    ---------------------------------------------------------------------------

    local markdown_writer = require("kanban.markdown.writer")

    markdown_writer.write = function(k, path)
      path = path:gsub("^~", os.getenv("HOME"))

      local lines = vim.list_extend({}, k.ops.markdown.header)

      for _, list in ipairs(k.items.lists) do
        vim.list_extend(lines, {
          "",
          "## " .. list.title,
          "",
        })

        local written_tasks = 0

        for _, task in ipairs(list.tasks) do
          if task_has_content(task) then
            if written_tasks > 0 then
              table.insert(lines, "")
            end

            for i, line in ipairs(task.lines) do
              if i == 1 then
                table.insert(lines, (task.check and "- [x] " or "- [ ] ") .. line)
              else
                table.insert(lines, "\t" .. line)
              end
            end

            written_tasks = written_tasks + 1
          end
        end
      end

      table.insert(lines, "")

      vim.list_extend(lines, k.ops.markdown.footer)

      local file, err = io.open(path, "w")

      if not file then
        vim.notify("Kanban konnte nicht gespeichert werden: " .. err, vim.log.levels.ERROR)
        return
      end

      for _, line in ipairs(lines) do
        file:write(line, "\n")
      end

      file:close()
    end

    ---------------------------------------------------------------------------
    -- Telescope: Nur Dateinamen statt vollständiger Pfade anzeigen
    ---------------------------------------------------------------------------

    local telescope_integration = require("kanban.integrations.telescope")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local conf = require("telescope.config").values

    telescope_integration.kanban_telescope = function(picker_opts)
      local handle = io.popen("rg '\\-+[\n\\s]+kanban-plugin: .+[\\n\\s]+\\-+' -lU ./")

      if not handle then
        return
      end

      local output = handle:read("*a")
      handle:close()

      local paths = {}

      for path in output:gmatch("[^\n]+") do
        table.insert(paths, path)
      end

      pickers
        .new(picker_opts or {}, {
          prompt_title = "Kanban.nvim",

          finder = finders.new_table({
            results = paths,

            entry_maker = function(path)
              return {
                value = path,
                display = vim.fn.fnamemodify(path, ":t"),
                ordinal = path,
              }
            end,
          }),

          sorter = conf.generic_sorter(picker_opts or {}),

          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()

              actions.close(prompt_bufnr)

              if selection then
                vim.cmd({
                  cmd = "KanbanOpen",
                  args = { selection.value },
                })
              end
            end)

            return true
          end,
        })
        :find()
    end

    ---------------------------------------------------------------------------
    -- Workaround: Verbliebene Kanban-Floating-Windows schließen
    ---------------------------------------------------------------------------

    local kwindow_close = require("kanban.fn.kwindow.close")

    local function close_kanban_floats()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)

        if config.relative ~= "" then
          local winhl = vim.wo[win].winhighlight

          -- Nur Floating Windows mit unseren Kanban-Highlights schließen.
          if
            winhl:find("KanbanTodoBackground", 1, true)
            or winhl:find("KanbanProgressBackground", 1, true)
            or winhl:find("KanbanDoneBackground", 1, true)
          then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end
    end

    local original_kwindow_close = kwindow_close.close

    kwindow_close.close = function(k)
      original_kwindow_close(k)

      -- Reguläre Task- und Spaltenfenster schließen.
      k.fn.tasks.close_all(k)
      k.fn.lists.close_all(k)

      -- Verwaiste Task-Fenster entfernen.
      close_kanban_floats()
    end

    kanban.fn.kwindow.close = kwindow_close.close

    ---------------------------------------------------------------------------
    -- Checkbox-Status automatisch an die Kanban-Spalte anpassen
    ---------------------------------------------------------------------------

    local take = require("kanban.fn.tasks.take")

    local function take_with_status(direction)
      return function(k)
        local focus = k.fn.tasks.utils.get_focus(k)

        if not focus then
          return
        end

        local target_num = focus.list_num + direction
        local target_list = k.items.lists[target_num]

        if not target_list then
          return
        end

        local source_list = k.items.lists[focus.list_num]
        local task = source_list.tasks[focus.task_num]

        if not task then
          return
        end

        -- Status entsprechend der Zielspalte setzen.
        -- DONE = erledigt, alle anderen Spalten = offen.
        local clone_task = require("kanban.utils").deepcopy(task)

        clone_task.check = target_list.title == "DONE" or target_list.title == "Done"

        -- Original entfernen und Kopie in Zielspalte einfügen.
        k.fn.tasks.delete(k)

        k.fn.tasks.add(k, target_num, clone_task, k.ops.move_position, true)
      end
    end

    take.left = take_with_status(-1)
    take.right = take_with_status(1)

    kanban.fn.tasks.take.left = take.left
    kanban.fn.tasks.take.right = take.right

    ---------------------------------------------------------------------------
    -- Workaround: Fehler beim Schließen des Kanban-Boards
    ---------------------------------------------------------------------------

    local user_command = require("kanban.user_command")

    user_command.del = function()
      local commands = {
        "KanbanTaskDelete",
        "KanbanTaskToggleComplete",
        "KanbanTakeRight",
        "KanbanTakeLeft",
        "KanbanTakeUp",
        "KanbanTakeDown",
        "KanbanMoveDown",
        "KanbanMoveUp",
        "KanbanMoveRight",
        "KanbanMoveLeft",
        "KanbanMoveTop",
        "KanbanMoveBottom",
        "KanbanTaskAdd",
        "KanbanTaskAddBottom",
        "KanbanTaskAddTop",
        "KanbanClose",
        "KanbanSave",
        "KanbanListDelete",
        "KanbanListRename",
        "KanbanListAdd",
        "KanbanTaskDescription",
        "KanbanTaskDescriptionSetHeader",
      }

      for _, name in ipairs(commands) do
        if vim.fn.exists(":" .. name) == 2 then
          vim.api.nvim_del_user_command(name)
        end
      end
    end

    ---------------------------------------------------------------------------
    -- Farben
    ---------------------------------------------------------------------------

    -- TODO
    vim.api.nvim_set_hl(0, "KanbanTodoTitle", {
      fg = "#81A1C1",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanTodoBorder", {
      fg = "#81A1C1",
    })

    vim.api.nvim_set_hl(0, "KanbanTodoText", {
      fg = "#81A1C1",
    })

    vim.api.nvim_set_hl(0, "KanbanTodoBackground", {
      fg = "#20242B",
      bg = "#81A1C1",
    })

    -- WIP
    vim.api.nvim_set_hl(0, "KanbanProgressTitle", {
      fg = "#D49A62",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanProgressBorder", {
      fg = "#D49A62",
    })

    vim.api.nvim_set_hl(0, "KanbanProgressText", {
      fg = "#D49A62",
    })

    vim.api.nvim_set_hl(0, "KanbanProgressBackground", {
      fg = "#20242B",
      bg = "#D49A62",
    })

    -- DONE
    vim.api.nvim_set_hl(0, "KanbanDoneTitle", {
      fg = "#A3BE8C",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanDoneBorder", {
      fg = "#A3BE8C",
    })

    vim.api.nvim_set_hl(0, "KanbanDoneText", {
      fg = "#A3BE8C",
    })

    vim.api.nvim_set_hl(0, "KanbanDoneBackground", {
      fg = "#20242B",
      bg = "#A3BE8C",
    })

    ---------------------------------------------------------------------------
    -- Zuordnung Spaltenname -> Stil
    ---------------------------------------------------------------------------

    local styles = {
      ["TODO"] = {
        title = "KanbanTodoTitle",
        border = "KanbanTodoBorder",
        text = "KanbanTodoText",
        background = "KanbanTodoBackground",
      },

      -- Kompatibilität mit bestehenden Boards
      ["ToDo"] = {
        title = "KanbanTodoTitle",
        border = "KanbanTodoBorder",
        text = "KanbanTodoText",
        background = "KanbanTodoBackground",
      },

      ["WIP (max. 3)"] = {
        title = "KanbanProgressTitle",
        border = "KanbanProgressBorder",
        text = "KanbanProgressText",
        background = "KanbanProgressBackground",
      },

      ["DONE"] = {
        title = "KanbanDoneTitle",
        border = "KanbanDoneBorder",
        text = "KanbanDoneText",
        background = "KanbanDoneBackground",
      },

      -- Kompatibilität mit bestehenden Boards
      ["Done"] = {
        title = "KanbanDoneTitle",
        border = "KanbanDoneBorder",
        text = "KanbanDoneText",
        background = "KanbanDoneBackground",
      },
    }

    ---------------------------------------------------------------------------
    -- Spalten
    ---------------------------------------------------------------------------

    local function highlight_list(_, list)
      local style = styles[list.title]

      if not style then
        return
      end

      -- Titel der Spalte einfärben.
      vim.api.nvim_buf_add_highlight(list.buf_nr, 0, style.title, 1, 0, -1)

      -- Spaltenhintergrund dunkel lassen, Rahmen einfärben.
      vim.api.nvim_set_option_value(
        "winhighlight",
        "NormalFloat:ListFloat,FloatBorder:" .. style.border,
        { win = list.win_id }
      )
    end

    require("kanban.fn.lists.highlight").highlight = highlight_list
    kanban.fn.lists.highlight = highlight_list

    ---------------------------------------------------------------------------
    -- Tasks
    ---------------------------------------------------------------------------

    -- Originale Highlight-Funktion sichern.
    -- Dadurch bleiben die eingebauten Highlights von kanban.nvim erhalten:
    -- Due-Dates, Tags, Completed-Status usw.
    local original_task_highlight = require("kanban.fn.tasks.highlight").highlight

    local function highlight_task(k, task)
      -- Zuerst das normale Highlighting von kanban.nvim ausführen.
      original_task_highlight(k, task)

      -------------------------------------------------------------------------
      -- Tags vollständig hervorheben
      -- Unterstützt Umlaute, ß, Bindestriche und Unterstriche
      -------------------------------------------------------------------------

      if task.buf_nr and vim.api.nvim_buf_is_valid(task.buf_nr) then
        local lines = vim.api.nvim_buf_get_lines(task.buf_nr, 0, -1, false)

        for i, line in ipairs(lines) do
          -- Tags am Zeilenanfang.
          local tag = line:match("^(#[^%s#]+)")

          if tag then
            vim.api.nvim_buf_add_highlight(task.buf_nr, 0, "TaskTag", i - 1, 0, #tag)
          end

          -- Tags nach Leerzeichen.
          for start_idx, whitespace, tag_text in line:gmatch("()(%s+)(#[^%s#]+)") do
            local start_col = start_idx - 1 + #whitespace

            vim.api.nvim_buf_add_highlight(task.buf_nr, 0, "TaskTag", i - 1, start_col, start_col + #tag_text)
          end
        end
      end

      -------------------------------------------------------------------------
      -- Aktuelle Spalte des Tasks ermitteln
      -------------------------------------------------------------------------

      local parent_list = nil

      for _, list in ipairs(k.items.lists) do
        for _, candidate in ipairs(list.tasks) do
          if candidate == task then
            parent_list = list
            break
          end
        end

        if parent_list then
          break
        end
      end

      if not parent_list then
        return
      end

      local style = styles[parent_list.title]

      if not style then
        return
      end

      -------------------------------------------------------------------------
      -- Hintergrund und Rahmen der Task-Karte
      -------------------------------------------------------------------------

      -- Normal und NormalFloat erhalten dieselbe Hintergrundfarbe.
      -- Dadurch sollen auch normale, nicht abgeschlossene Tasks
      -- vollständig eingefärbt werden.
      vim.api.nvim_set_option_value(
        "winhighlight",
        table.concat({
          "Normal:" .. style.background,
          "NormalFloat:" .. style.background,
          "FloatBorder:" .. style.border,
        }, ","),
        { win = task.win_id }
      )
    end

    require("kanban.fn.tasks.highlight").highlight = highlight_task
    kanban.fn.tasks.highlight = highlight_task
  end,

  keys = {
    ---------------------------------------------------------------------------
    -- Kanban-Board über Telescope finden
    ---------------------------------------------------------------------------

    {
      "<leader>kf",

      function()
        local kanban = require("kanban")

        -- Telescope ist nur die Dateiauswahl, noch kein aktives Board.
        if kanban.active then
          vim.notify("Ein Kanban-Board ist bereits aktiv.", vim.log.levels.WARN)
          return
        end

        -- Das Plugin setzt active bereits beim Öffnen von Telescope auf true.
        -- Nach dem Start der Auswahl zurücksetzen, damit das gewählte Board
        -- anschließend über KanbanOpen geöffnet werden kann.
        vim.cmd("KanbanOpen telescope")
        kanban.active = false
      end,

      desc = "Kanban: Find board",
    },

    ---------------------------------------------------------------------------
    -- Aktuelle Markdown-Datei als Board öffnen
    ---------------------------------------------------------------------------

    {
      "<leader>kb",

      function()
        local kanban = require("kanban")

        -- Ein geöffnetes Board schließen.
        if kanban.active then
          if vim.fn.exists(":KanbanClose") == 2 then
            local board_buf = vim.fn.bufnr(kanban.kanban_md_path or "")

            vim.cmd("KanbanClose")

            if board_buf > 0 and vim.api.nvim_buf_is_loaded(board_buf) then
              if vim.bo[board_buf].modified then
                vim.notify("Kanban-Datei wurde geändert; Buffer nicht automatisch neu geladen.", vim.log.levels.WARN)
              else
                vim.api.nvim_buf_call(board_buf, function()
                  vim.cmd("edit!")
                end)
              end
            end
          else
            -- Fehlerhaften Zustand zurücksetzen.
            kanban.active = false

            vim.notify("Kein aktives Kanban-Board gefunden. Status zurückgesetzt.", vim.log.levels.WARN)
          end

          return
        end

        -- Aktuelle Markdown-Datei als Board öffnen.
        local file = vim.api.nvim_buf_get_name(0)

        if vim.bo.buftype ~= "" or not file:match("%.md$") then
          vim.notify("KanbanOpen benötigt einen Markdown-Buffer (.md).", vim.log.levels.WARN)
          return
        end

        -- Das Plugin liest die Datei von der Platte,
        -- nicht den aktuellen Buffer.
        if vim.bo.modified then
          vim.cmd("write!")
        end

        vim.cmd({
          cmd = "KanbanOpen",
          args = { file },
        })
      end,

      desc = "Kanban: Toggle board",
    },

    ---------------------------------------------------------------------------
    -- Neues Kanban-Board im aktuellen Oil-Verzeichnis erstellen
    -- Eine leere Aufgabe nur in TODO anlegen und direkt bearbeiten
    ---------------------------------------------------------------------------

    {
      "<leader>kc",

      function()
        local oil = require("oil")

        local oil_buf = vim.api.nvim_get_current_buf()
        local dir = oil.get_current_dir(oil_buf)

        if not dir then
          vim.notify("KanbanCreate muss aus einem Oil-Buffer aufgerufen werden.", vim.log.levels.WARN)
          return
        end

        vim.ui.input({
          prompt = "Kanban-Name: ",
        }, function(name)
          name = vim.trim(name or "")

          if name == "" then
            return
          end

          name = name:gsub("^kanban%-", "")
          name = name:gsub("%.md$", "")

          local file = vim.fs.joinpath(dir, "kanban-" .. name .. ".md")

          if vim.fn.filereadable(file) == 1 then
            vim.notify("Kanban-Datei existiert bereits: " .. file, vim.log.levels.WARN)
            return
          end

          -- Kanban-Datei mit den konfigurierten Standardspalten erstellen.
          vim.cmd({
            cmd = "KanbanCreate",
            args = { file },
          })

          if vim.fn.filereadable(file) ~= 1 then
            return
          end

          -- Neue Datei öffnen.
          vim.cmd({
            cmd = "edit",
            args = { file },
          })

          -- Erste leere Aufgabe ausschließlich unter TODO einfügen.
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

          local todo_line = nil

          for i, line in ipairs(lines) do
            if line == "## TODO" then
              todo_line = i
              break
            end
          end

          if not todo_line then
            vim.notify("Kanban: TODO-Spalte nicht gefunden.", vim.log.levels.ERROR)
            return
          end

          -- Aufgabe direkt unter der TODO-Überschrift einfügen.
          vim.api.nvim_buf_set_lines(0, todo_line, todo_line, false, { "- [ ] " })

          -- Datei speichern.
          vim.cmd("write!")

          -- Symlink im zentralen iCloud-Verzeichnis erstellen.
          create_icloud_symlink(file)

          -- Cursor am Ende der Zeile positionieren.
          vim.api.nvim_win_set_cursor(0, { todo_line + 1, 5 })

          -- Insert-Modus am Zeilenende starten.
          vim.cmd("startinsert!")
        end)
      end,

      desc = "Kanban: Create board in Oil directory",
    },
  },
}
