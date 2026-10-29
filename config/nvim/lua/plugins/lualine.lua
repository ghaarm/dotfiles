-- return {
--   "nvim-lualine/lualine.nvim",
--   dependencies = { "nvim-tree/nvim-web-devicons" },
--   config = function()
--     local lualine = require("lualine")
--     local lazy_status = require("lazy.status") -- to configure lazy pending updates count
--
--     local colors = {
--       blue = "#65D1FF", -- von josean
--       -- blue = "#00008B", -- von mir dunkles blau
--       -- green = "#3EFFDC", -- von josean
--       -- green = "#006400", -- von mir dunkelgrün
--       green = "#b8bb26",  -- von mir dunkelgrün nach gruvbox https://github.com/morhetz/gruvbox
--       -- violet = "#FF61EF", -- von josean
--       violet = "#d3869b", -- von mir purple nach Gruvbox
--       yellow = "#FFDA7B",
--       -- red = "#FF4A4A", -- von josean
--       -- red = "#8B0000", -- von mir dukles rot
--       red = "#d65d0e", -- von mir orange nach gruvbox https://github.com/morhetz/gruvbox
--       fg = "#c3ccdc",
--       bg = "#112638",
--       inactive_bg = "#2c3043",
--     }
--
--     local my_lualine_theme = {
--       normal = {
--         a = { bg = colors.green, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       insert = {
--         a = { bg = colors.red, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       visual = {
--         a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       command = {
--         a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       replace = {
--         a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
--         b = { bg = colors.bg, fg = colors.fg },
--         c = { bg = colors.bg, fg = colors.fg },
--       },
--       inactive = {
--         a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
--         b = { bg = colors.inactive_bg, fg = colors.semilightgray },
--         c = { bg = colors.inactive_bg, fg = colors.semilightgray },
--       },
--     }
--
--     -- configure lualine with modified theme
--     lualine.setup({
--       options = {
--         -- theme = my_lualine_theme,
--         -- theme = 'gruvbox-flat',
--
--         -- theme = "kanagawa",
--         theme = "nightfox",
--         -- theme = "catppuccin",
--         component_separators = "", -- Entfernt die kleinen Pfeile zwischen Komponenten
--         -- section_separators = "", -- Entfernt die großen Pfeile zwischen den Sektionen
--       },
--
--       sections = {
--         lualine_a = { 'mode' },   -- Zeigt den Modus wie NORMAL, INSERT etc.
--         lualine_b = { 'branch' }, -- Zeigt den Git-Branch wie main
--
--         lualine_c = {
--           '%=', -- Aligner für die Mitte
--           {
--             function()
--               -- Absoluter Pfad der Datei
--               local filepath = vim.fn.expand('%:p')
--               local path_sep = package.config:sub(1, 1) -- OS-spezifischer Separator
--
--               -- Zerlege den Pfad in Teile
--               local parts = {}
--               for part in string.gmatch(filepath, '[^' .. path_sep .. ']+') do
--                 table.insert(parts, part)
--               end
--
--               -- Letzte 3 Ordner + Dateiname
--               local start_idx = math.max(#parts - 3, 1)
--               local display_path = table.concat(vim.list_slice(parts, start_idx), path_sep)
--
--               -- Füge den Dateinamen hinzu
--               local filename = vim.fn.expand('%:t')
--
--               -- Gesamter Pfad inkl. Dateiname
--               return display_path .. path_sep .. filename
--             end,
--             shorting_target = 30, -- Kürzt den Pfad bei Bedarf
--           },
--           -- {
--           --   'filename',
--           --   path = 2,             -- 2 Absoluter Pfad, q relativer Pfad
--           --   shorting_target = 30, -- Kürzt den Pfad bei Bedarf
--           -- },
--           -- '%=',                   -- Aligner für die Mitte
--         },
--
--         lualine_x = { -- Rechtsbündige Infos
--           {
--             possession_name,
--             cond = function()
--               local ok, session = pcall(require, "possession.session")
--               return ok and (session.get_session_name() or "") ~= ""
--             end,
--           },
--           {
--             lazy_status.updates,
--             cond = lazy_status.has_updates,
--             color = { fg = "#ff9e64" },
--           },
--           { 'encoding' },
--           { 'fileformat' },
--           { 'filetype' },
--         },
--
--         lualine_y = {},
--         lualine_z = {},
--       }
--     })
--   end,
-- }
--
-- für lualine und possessions

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")
    local kanban_project_name = require("core.functions.winbar").kanban_project_name

    -- IMPORTANT: Define this before lualine.setup()
    local function possession_name()
      local ok, session = pcall(require, "possession.session")
      if not ok then
        return ""
      end
      local name = session.get_session_name()
      if not name or name == "" then
        return ""
      end
      return "󱂬 " .. name
    end

    local colors = {
      blue = "#65D1FF",
      green = "#b8bb26",
      violet = "#d3869b",
      yellow = "#FFDA7B",
      red = "#d65d0e",
      fg = "#c3ccdc",
      bg = "#112638",
      inactive_bg = "#2c3043",
    }

    local my_lualine_theme = {
      normal = {
        a = { bg = colors.green, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.red, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.fg },
        c = { bg = colors.inactive_bg, fg = colors.fg },
      },
    }

    lualine.setup({
      options = {
        theme = "nightfox",
        component_separators = "",
        disabled_filetypes = {
          statusline = { "alpha" }, -- Alpha-Dashboard nicht zeichnen
        },
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },

        lualine_c = {
          "%=",
          {
            function()
              local project = kanban_project_name(vim.api.nvim_get_current_buf())
              if project then
                return project
              end

              local filepath = vim.fn.expand("%:p")
              if not filepath or filepath == "" then
                return ""
              end

              local path_sep = package.config:sub(1, 1)
              local parts = {}
              for part in string.gmatch(filepath, "[^" .. path_sep .. "]+") do
                table.insert(parts, part)
              end
              if #parts == 0 then
                return ""
              end

              local start_idx = math.max(#parts - 3, 1)
              local display_path = table.concat(vim.list_slice(parts, start_idx), path_sep)
              local filename = vim.fn.expand("%:t")

              if display_path == "" then
                return filename or ""
              end
              return display_path .. path_sep .. (filename or "")
            end,
            shorting_target = 30,
          },
        },

        lualine_x = {
          {
            possession_name,
            cond = function()
              local ok, session = pcall(require, "possession.session")
              return ok and (session.get_session_name() or "") ~= ""
            end,
          },
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },

        lualine_y = {},
        lualine_z = {
          {
            function()
              return "L:" .. vim.api.nvim_buf_line_count(0)
            end,
          },
          { "location" },
        },
      },

      -- IMPORTANT: Prevent nil sections during refresh (fixes your stacktrace)
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            function()
              return kanban_project_name(vim.api.nvim_get_current_buf()) or ""
            end,
            cond = function()
              return kanban_project_name(vim.api.nvim_get_current_buf()) ~= nil
            end,
          },
          {
            "filename",
            cond = function()
              return kanban_project_name(vim.api.nvim_get_current_buf()) == nil
            end,
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
