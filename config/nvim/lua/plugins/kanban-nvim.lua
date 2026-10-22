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

    ---------------------------------------------------------------------------
    -- Zuordnung Spaltenname -> Stil
    ---------------------------------------------------------------------------

    local styles = {
      ["TODO"] = {
        title = "KanbanTodoTitle",
        border = "KanbanTodoBorder",
        text = "KanbanTodoText",
      },

      -- Kompatibilität mit bestehenden Boards
      ["ToDo"] = {
        title = "KanbanTodoTitle",
        border = "KanbanTodoBorder",
        text = "KanbanTodoText",
      },

      ["WIP (max. 3)"] = {
        title = "KanbanProgressTitle",
        border = "KanbanProgressBorder",
        text = "KanbanProgressText",
      },

      ["DONE"] = {
        title = "KanbanDoneTitle",
        border = "KanbanDoneBorder",
        text = "KanbanDoneText",
      },

      -- Kompatibilität mit bestehenden Boards
      ["Done"] = {
        title = "KanbanDoneTitle",
        border = "KanbanDoneBorder",
        text = "KanbanDoneText",
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

      -- Außenrahmen der Spalte einfärben
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
    --
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
      -- Rahmen der Task-Karte
      -------------------------------------------------------------------------

      vim.api.nvim_set_option_value(
        "winhighlight",
        "NormalFloat:TaskFloat,FloatBorder:" .. style.border,
        { win = task.win_id }
      )

      -------------------------------------------------------------------------
      -- Titel der Task-Karte
      -------------------------------------------------------------------------

      -- kanban.nvim setzt für die erste Zeile normalerweise "TaskTitle".
      -- Wir überschreiben dieses Highlight anschließend mit der Farbe
      -- der aktuellen Spalte.
      vim.api.nvim_buf_add_highlight(task.buf_nr, 0, style.text, 0, 0, -1)
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
