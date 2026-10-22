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

return {
  "arakkkkk/kanban.nvim",

  dependencies = {
    "nvim-telescope/telescope.nvim",
  },

  opts = {
    move_position = "top",
    add_position = "bottom",

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

      -- Titel der Spalte einfärben
      vim.api.nvim_buf_add_highlight(list.buf_nr, 0, style.title, 1, 0, -1)

      -- Spaltenhintergrund dunkel lassen, Rahmen einfärben
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
      "<leader>ko",
      function()
        local file = vim.api.nvim_buf_get_name(0)

        -- Nur reguläre Markdown-Dateien als Kanban-Board öffnen.
        if vim.bo.filetype == "oil" or not file:match("%.md$") then
          vim.notify("KanbanOpen benötigt einen Markdown-Buffer (.md).", vim.log.levels.WARN)
          return
        end

        vim.cmd({
          cmd = "KanbanOpen",
          args = { file },
        })
      end,
      desc = "Kanban: Open current file as board",
    },

    ---------------------------------------------------------------------------
    -- Neues Kanban-Board im aktuellen Oil-Verzeichnis erstellen
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

          vim.cmd({
            cmd = "KanbanCreate",
            args = { file },
          })

          vim.api.nvim_buf_call(oil_buf, function()
            require("oil.actions").refresh.callback({
              force = true,
            })
          end)

          vim.cmd({
            cmd = "KanbanOpen",
            args = { file },
          })
        end)
      end,
      desc = "Kanban: Create board in Oil directory",
    },
  },
}
