-- https://github.com/arakkkkk/kanban.nvim
--
-- kanban.nvim can provide in-buffer completion for due dates (@...) and tags (#...) via optional completion engines. The plugin works without any of these; install only if you want completion.
-- What gets completed
--
--     @ due tokens are expanded to dates: @today, @2d, @1w, @2m, @1y, @/MM/DD, @//DD, weekdays @su..@sa, and next-week variants like @nmo, @nwe, etc. Candidates insert the concrete date like @2025/09/07.
--     # tags are suggested from existing task tags found in the current Kanban board (unique, case-insensitive match).
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
        "ToDo",
        "In Progress",
        "Done",
      },
    },
  },
  config = function(_, opts)
    require("kanban").setup(opts)

    -- Vorläufige Farben; später durch deine Theme-Farben ersetzen.
    vim.api.nvim_set_hl(0, "KanbanTodoTitle", {
      fg = "#81A1C1",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanProgressTitle", {
      fg = "#D08770",
      bold = true,
    })

    vim.api.nvim_set_hl(0, "KanbanDoneTitle", {
      fg = "#A3BE8C",
      bold = true,
    })

    -- Unterschiedliche Highlights abhängig vom Namen der Spalte.
    local function highlight_list(_, list)
      local highlights = {
        ["To Do"] = "KanbanTodoTitle",
        ["In Progress"] = "KanbanProgressTitle",
        ["Done"] = "KanbanDoneTitle",
      }

      local group = highlights[list.title] or "ListTitle"

      vim.api.nvim_buf_add_highlight(list.buf_nr, 0, group, 1, 0, -1)

      vim.api.nvim_set_option_value("winhighlight", "NormalFloat:ListFloat", { win = list.win_id })
    end

    -- Modul überschreiben
    require("kanban.fn.lists.highlight").highlight = highlight_list

    -- Vor allem aber die vom Kanban-Objekt verwendete Funktion überschreiben
    local kanban = require("kanban")
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
