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
      list_head = "## ",
      due_format = "YYYY-MM-DD",

      default_lists = {
        "To Do",
        "In Progress",
        "Done",
      },
    },
  },

  keys = {
    -- -----------------------------------------------------
    -- Vorhandenes Kanban-Board über Telescope öffnen
    -- -----------------------------------------------------

    {
      "<leader>ko",
      "<cmd>KanbanOpen telescope<cr>",
      desc = "Kanban: Open board",
    },

    -- -----------------------------------------------------
    -- Neues Kanban-Board im aktuellen Oil-Verzeichnis
    -- -----------------------------------------------------

    {
      "<leader>kc",
      function()
        local oil = require("oil")

        -- Oil-Buffer merken, damit wir ihn nach dem Erstellen aktualisieren können.
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

          -- Board erstellen.
          vim.cmd({
            cmd = "KanbanCreate",
            args = { file },
          })

          -- Oil-Buffer aktualisieren.
          vim.api.nvim_buf_call(oil_buf, function()
            require("oil.actions").refresh.callback({
              force = true,
            })
          end)

          -- Board direkt öffnen.
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
