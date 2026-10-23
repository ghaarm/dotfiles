-- Andrew Courter https://www.youtube.com/watch?v=q1QhV-24DNA

return {
  "stevearc/oil.nvim",

  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    require("oil").setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,

      buf_options = {
        buflisted = true,
        bufhidden = "hide",
      },

      view_options = {
        show_hidden = true,
        natural_order = true,
        case_insensitive = true,

        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
      },

      win_options = {
        wrap = true,
      },

      keymaps = {
        ["R"] = "actions.refresh",
        ["<C-l>"] = "actions.refresh",
        ["<Esc>"] = {
          callback = function()
            require("core.functions.oil-selection").toggle()
          end,
          mode = "n",
          desc = "Eintrag markieren/entmarkieren",
        },

        -- ["<leader>ga"] = function()
        ["ga"] = function()
          local oil = require("oil")
          local image_preview = require("core.functions.bild-preview-mac")
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()

          if not entry or not dir then
            vim.notify("Kein Oil-Dateieintrag unter dem Cursor.", vim.log.levels.WARN)
            return
          end

          if entry.type == "directory" then
            vim.notify("Der ausgewählte Eintrag ist ein Ordner.", vim.log.levels.INFO)
            return
          end

          local fullpath = vim.fs.normalize(vim.fs.joinpath(dir, entry.name))

          if not image_preview.is_supported_image_path(fullpath) then
            vim.notify("Nur PNG- und JPEG-Dateien werden unterstützt.", vim.log.levels.INFO)
            return
          end

          image_preview.open_path_in_preview(fullpath)
        end,
        ["<CR>"] = function()
          local oil = require("oil")
          local image_preview = require("core.functions.bild-preview-mac")
          local entry = oil.get_cursor_entry()

          if not entry then
            return
          end

          local dir = oil.get_current_dir() or ""
          local path = vim.fs.normalize(vim.fs.joinpath(dir, entry.name))
          local lower_path = path:lower()

          -- Bilder mit Preview im Bearbeitungsmodus öffnen
          if entry.type ~= "directory" and image_preview.is_supported_image_path(lower_path) then
            image_preview.open_path_in_preview(path)
            return
          end

          -- PDF mit Sioyek öffnen
          if entry.type ~= "directory" and lower_path:match("%.pdf$") then
            if vim.fn.executable("sioyek") ~= 1 then
              vim.notify("sioyek nicht im PATH gefunden", vim.log.levels.WARN)
              return
            end

            vim.fn.jobstart({ "sioyek", path }, {
              detach = true,
            })
            return
          end

          -- DOCX mit Word öffnen
          if entry.type ~= "directory" and lower_path:match("%.docx$") then
            vim.fn.jobstart({
              "open",
              "-a",
              "Microsoft Word",
              path,
            }, {
              detach = true,
            })
            return
          end

          -- XLS/XLSX mit Excel öffnen
          if entry.type ~= "directory" and (lower_path:match("%.xls$") or lower_path:match("%.xlsx$")) then
            vim.fn.jobstart({
              "open",
              "-a",
              "Microsoft Excel",
              path,
            }, {
              detach = true,
            })
            return
          end

          require("oil.actions").select.callback()
        end,
      },
    })
  end,

  keys = {
    {
      "-",
      "<cmd>Oil<cr>",
      desc = "Open parent directory",
    },
  },
}
