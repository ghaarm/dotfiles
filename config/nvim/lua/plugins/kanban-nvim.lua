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

    -- Farben für Titel und Rahmen
    vim.api.nvim_set_hl(0, "KanbanTodoTitle", {
      fg = "#81A1C1",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanTodoBorder", {
      fg = "#81A1C1",
    })

    vim.api.nvim_set_hl(0, "KanbanProgressTitle", {
      fg = "#D49A62",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanProgressBorder", {
      fg = "#D49A62",
    })

    vim.api.nvim_set_hl(0, "KanbanDoneTitle", {
      fg = "#A3BE8C",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanDoneBorder", {
      fg = "#A3BE8C",
    })

    -- Unterschiedliche Highlights abhängig vom Namen der Spalte.
    local function highlight_list(_, list)
      local styles = {
        -- Neue Namen
        ["TODO"] = {
          title = "KanbanTodoTitle",
          border = "KanbanTodoBorder",
        },

        ["WIP (max. 3)"] = {
          title = "KanbanProgressTitle",
          border = "KanbanProgressBorder",
        },

        ["DONE"] = {
          title = "KanbanDoneTitle",
          border = "KanbanDoneBorder",
        },

        -- Kompatibilität mit bestehenden Boards
        ["ToDo"] = {
          title = "KanbanTodoTitle",
          border = "KanbanTodoBorder",
        },

        ["Done"] = {
          title = "KanbanDoneTitle",
          border = "KanbanDoneBorder",
        },
      }

      local style = styles[list.title]

      if not style then
        return
      end

      -- Titel einfärben
      vim.api.nvim_buf_add_highlight(list.buf_nr, 0, style.title, 1, 0, -1)

      -- Außenrahmen der jeweiligen Spalte einfärben
      vim.api.nvim_set_option_value(
        "winhighlight",
        "NormalFloat:ListFloat,FloatBorder:" .. style.border,
        { win = list.win_id }
      )
    end

    -- Highlight-Funktion des Plugins überschreiben
    require("kanban.fn.lists.highlight").highlight = highlight_list
    kanban.fn.lists.highlight = highlight_list
  end,

  keys = {
    -- Kanban-Board über Telescope finden
    {
      "<leader>kf",
      "<cmd>KanbanOpen telescope<cr>",
      desc = "Kanban: Find board",
    },

    -- Aktuelle Kanban-Markdown-Datei als Board öffnen
    {
      "<leader>ko",
      function()
        local file = vim.api.nvim_buf_get_name(0)

        if file == "" then
          vim.notify("Aktueller Buffer hat keinen Dateipfad.", vim.log.levels.WARN)
          return
        end

        vim.cmd({
          cmd = "KanbanOpen",
          args = { file },
        })
      end,
      desc = "Kanban: Open current file as board",
    },

    -- Neues Kanban-Board im aktuellen Oil-Verzeichnis erstellen
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
