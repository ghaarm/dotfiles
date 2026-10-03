return {
  "nvim-telescope/telescope.nvim",
  -- branch = "0.1.x",
  -- branch = "master",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-bibtex.nvim",
    "ThePrimeagen/harpoon", -- Harpoon als Abhängigkeit hinzufügen
    "nvim-telescope/telescope-media-files.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local bibtex_actions = require("telescope-bibtex.actions")
    local actions = require("telescope.actions")

    local builtin = require("telescope.builtin") -- für telescope buffers
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")
    -- -- HIER NEU: für Telescope Buffer
    -- local builtin = require("telescope.builtin")
    -- local themes = require("telescope.themes")
    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        layout_strategy = "flex",
        layout_config = {
          width = 0.95,
          height = 0.90,

          flex = {
            flip_columns = 100, -- ab welcher Bildschirmbreite (Spalten wird der preview in vertical gewechselt)
          },

          horizontal = {
            preview_width = 0.5,
            preview_cutoff = 100,
          },

          vertical = {
            preview_height = 0.45,
            preview_cutoff = 1, -- 1 = preview soll immer sichtbar sein, auch bei kleinen fenstern
          },
        },
        file_ignore_patterns = {
          "%.aux$",
          "%.bbl$",
          "%.bcf$",
          "%.blg$",
          "%.fdb_latexmk$",
          "%.fls$",
          "%.lof$",
          "%.log$",
          "%.out$",
          "%.run.xml$",
          "%.synctex%.gz$",
        },
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.smart_open_with_trouble,
          },
        },
      },
      -- um im picker buffer zu löschen
      pickers = {
        buffers = {
          sort_lastused = true,
          ignore_current_buffer = false,
          previewer = true,
          mappings = {
            n = {
              ["dd"] = actions.delete_buffer,
            },
            -- i = {
            --   ["<C-d>"] = actions.delete_buffer, -- optional
            -- },
            i = {
              ["dd"] = actions.delete_buffer, -- optional
            },
          },
        },
      },
      extensions = {
        bibtex = {
          depth = 1,
          custom_formats = {
            { id = "no_cite", cite_marker = "#label#" },
            -- { id = "no_cite", cite_marker = "%s" },
          },
          format = "no_cite",
          global_files = { "/Users/g/Library/texmf/bibtex/bib/Zotero.bib" },
          search_keys = { "author", "year", "title" },
          citation_format = "{{author}} ({{year}}), {{title}}.",
          citation_trim_firstname = true,
          citation_max_auth = 2,
          context = false,
          context_fallback = true,
          wrap = false,
          mappings = {
            i = {
              ["<CR>"] = bibtex_actions.key_append("%s"),
              ["<C-e>"] = bibtex_actions.entry_append,
              ["<C-c>"] = bibtex_actions.citation_append("{{author}} ({{year}}), {{title}}."),
            },
          },
        },
        media_files = {
          -- filetypes whitelist
          -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
          filetypes = { "png", "webp", "jpg", "jpeg", "pdf" },
          -- find command (defaults to `fd`)
          find_cmd = "rg",
        },
      },
    })

    telescope.load_extension("bibtex")
    telescope.load_extension("fzf")
    telescope.load_extension("todo-comments")
    telescope.load_extension("media_files")
    pcall(telescope.load_extension, "possession")
    -- Harpoon integration
    local harpoon = require("harpoon")
    harpoon:setup({})

    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    vim.keymap.set("n", "<C-e>", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Open harpoon window" })

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", function()
      require("telescope.builtin").find_files({
        previewer = true,
        hidden = false,
        no_ignore = false,
        no_ignore_parent = false,
      })
    end, { desc = "Fuzzy find files in cwd" })

    keymap.set("n", "<leader>fp", function()
      require("telescope.builtin").find_files({
        previewer = false,
        hidden = false,
        no_ignore = false,
        no_ignore_parent = false,
      })
    end, { desc = "Fuzzy find files in cwd" })

    keymap.set("n", "<leader>fi", function()
      local parent = vim.fn.expand("%:p:h:h:h") -- parent sucht von der aktuellen Datei aus vs cwd s.u. geht vom cwd aus, :h = ein parent Ordner
      require("telescope.builtin").find_files({
        cwd = parent,
        hidden = true,
        no_ignore = true,
        no_ignore_parent = true,
      })
    end, { desc = "find ALL files from 3 levels up" })

    -- keymap.set("n", "<leader>fi", function() -- zeigt alle ignorierten files, gitignore und übergeordnete ordner
    --   require("telescope.builtin").find_files({
    --     cwd = "..", -- damit auch übergeordnete Ordner durchsucht werden, geht vom cwd aus
    --     hidden = true,
    --     no_ignore = true,
    --     no_ignore_parent = true,
    --   })
    -- end, { desc = "find files in parent dir incl. ignored)" })

    -- keymap.set("n", "<leader>fF", function()
    keymap.set("n", "<leader>fP", function()
      require("telescope.builtin").find_files({
        hidden = false, -- optional
        no_ignore = false,
        no_ignore_parent = false,
      })
    end, { desc = "Find files (restricted)" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    -- keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    -- Alle TODOs im aktuellen Working Directory
    keymap.set("n", "<leader>fta", function()
      telescope.extensions["todo-comments"].todo({})
    end, {
      desc = "Find all todos",
    })

    -- TODOs ab dem Verzeichnis der aktuellen Datei
    keymap.set("n", "<leader>ftp", function()
      telescope.extensions["todo-comments"].todo({
        cwd = vim.fn.expand("%:p:h"),
      })
    end, {
      desc = "Find todos in current path",
    })

    keymap.set("n", "<leader>fth", function()
      local make_entry = require("telescope.make_entry")

      local default_entry_maker = make_entry.gen_from_vimgrep({})

      builtin.grep_string({
        prompt_title = "TODOs in current file",

        search = [[TODO|FIX|FIXME|BUG|HACK|WARN|WARNING|PERF|PERFORMANCE|NOTE|TEST]],

        use_regex = true,

        search_dirs = {
          vim.fn.expand("%:p"),
        },

        -- entry_maker = function(line)
        --   local entry = default_entry_maker(line)
        --
        --   if not entry then
        --     return nil
        --   end
        --
        --   -- Text direkt aus der vimgrep-Ausgabe holen:
        --   -- datei:zeile:spalte:text
        --   local text = line:match("^.-:%d+:%d+:(.*)$") or ""
        --
        --   -- führende Leerzeichen entfernen
        --   text = text:gsub("^%s+", "")
        --
        --   entry.display = string.format("%s  %d:%d", text, entry.lnum or 0, entry.col or 0)
        --
        --   return entry
        -- end,
        entry_maker = function(line)
          local entry = default_entry_maker(line)

          if not entry then
            return nil
          end

          -- Text aus der vimgrep-Ausgabe holen
          local text = line:match("^.-:%d+:%d+:(.*)$") or ""

          -- führende Leerzeichen entfernen
          text = text:gsub("^%s+", "")

          local display = string.format("%s  %d:%d", text, entry.lnum or 0, entry.col or 0)

          entry.display = function()
            return display,
              {
                {
                  { 0, #text },
                  "TodoFgTODO",
                },
              }
          end

          return entry
        end,
      })
    end, {
      desc = "Find todos in current file",
    })
    keymap.set("n", "<leader>ftm", function()
      local make_entry = require("telescope.make_entry")

      local default_entry_maker = make_entry.gen_from_vimgrep({})

      builtin.grep_string({
        prompt_title = "MEMOs in current file",

        -- search = [[\bMEMO:]],
        search = [[\b(MEMO|NOTE):]],
        use_regex = true,

        search_dirs = {
          vim.fn.expand("%:p"),
        },

        entry_maker = function(line)
          local entry = default_entry_maker(line)

          if not entry then
            return nil
          end

          -- Text aus der vimgrep-Ausgabe holen
          local text = line:match("^.-:%d+:%d+:(.*)$") or ""

          -- führende Leerzeichen entfernen
          text = text:gsub("^%s+", "")

          local display = string.format("%s  %d:%d", text, entry.lnum or 0, entry.col or 0)

          -- entry.display = function()
          --   return display,
          --     {
          --       {
          --         { 0, #text },
          --         "TodoFgWARN",
          --       },
          --     }
          -- end
          entry.display = function()
            local highlight

            if text:match("%f[%w]NOTE:") then
              highlight = "TodoFgNOTE"
            else
              highlight = "TodoFgWARN"
            end

            return display,
              {
                {
                  { 0, #text },
                  highlight,
                },
              }
          end
          return entry
        end,
      })
    end, {
      desc = "Find MEMO and NOTEs in current file",
    })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Fuzzy find open buffers" })

    -- keymap.set("n", "<leader>fb", function()
    --   builtin.buffers({
    --     sort_lastused = true,
    --     ignore_current_buffer = false,
    --     previewer = true,
    --   })
    -- end, { desc = "Fuzzy find open buffers" })
    keymap.set("n", "<leader>fB", "<cmd>Telescope bibtex<cr>", { desc = "Search BibTeX entries" })
    keymap.set("i", "<D-i>", "<cmd>Telescope bibtex<cr>", { desc = "Open Telescope BibTeX search" }) -- D steht für die Command taste

    -- keymap.set("n", "<S-h>", function()
    --   builtin.buffers(themes.get_ivy({
    --     sort_mru = true,
    --     sort_lastused = true,
    --     ignore_current_buffer = true,
    --     initial_mode = "normal", -- optional
    --   }))
    -- end, { desc = "[P]Open telescope buffers" })
    --
    -- multigrep von tj devries https://www.youtube.com/watch?v=xdXE1tOT-qg
    require("plugins.telescope.multigrep").setup()
    local function set_telescope_prompt_orange()
      local orange = "#d78700" -- dunkles Orange; alternativ: "#c25f00"

      -- Text im Eingabefeld
      vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = orange })

      -- Das Prefix links vom Prompt (Lupe / >)
      vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = orange })

      -- Rahmen um das Prompt-Fenster
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = orange })

      -- Optional: Titel des Prompt-Fensters
      vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = orange, bold = true })

      -- Optional: Cursor im Prompt gut sichtbar (je nach Theme)
      -- vim.api.nvim_set_hl(0, "TelescopePromptCursor", { fg = orange })
    end

    -- Bei jedem Colorscheme erneut anwenden
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_telescope_prompt_orange,
    })

    -- Sofort anwenden (falls Colorscheme schon aktiv ist)
    set_telescope_prompt_orange()
  end,
}
