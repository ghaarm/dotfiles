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
    markdown = {
      description_folder = "./tasks/",
      list_head = "## ",
    },
  },

  keys = {
    {
      "<leader>ko",
      "<cmd>KanbanOpen telescope<cr>",
      desc = "Kanban: Open board",
    },

    {
      "<leader>kc",
      function()
        local oil = require("oil")
        local dir = oil.get_current_dir()

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

          -- Falls versehentlich kanban- oder .md mit eingegeben wurde.
          name = name:gsub("^kanban%-", "")
          name = name:gsub("%.md$", "")

          local file = vim.fs.joinpath(dir, "kanban-" .. name .. ".md")

          vim.cmd("KanbanCreate " .. vim.fn.fnameescape(file))
        end)
      end,
      desc = "Kanban: Create board in Oil directory",
    },
  },
}
