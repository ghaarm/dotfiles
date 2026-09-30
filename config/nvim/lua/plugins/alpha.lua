-- Ben Brast Mckie
return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "jedrzejboczar/possession.nvim",
    -- "Shatur/neovim-session-manager",
  },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header
    dashboard.section.header.val = {
      -- "                                                                       ",
      -- "                                                                     ",
      -- "       ████ ██████           █████      ██                     ",
      -- "      ███████████             █████                             ",
      -- "      █████████ ███████████████████ ███   ███████████   ",
      -- "     █████████  ███    █████████████ █████ ██████████████   ",
      -- "    █████████ ██████████ █████████ █████ █████ ████ █████   ",
      -- "  ███████████ ███    ███ █████████ █████ █████ ████ █████  ",
      -- " ██████  █████████████████████ ████ █████ █████ ████ ██████ ",
      -- "                                                                       ",
      -- "                                                                       ",
      "                                                        ",
      "       ████ ██████          ██                     ",
      "      ███████████                                    ",
      "      █████████   ████████ ███   ███████████   ",
      "     █████████     ████████ █████ ██████████████   ",
      "    █████████       ███████ █████ █████ ████ █████   ",
      "  ███████████        ██████ █████ █████ ████ █████  ",
      " ██████  ███          ████ █████ █████ ████ ██████ ",
      "                                                           ",
    }

    -- -- Set header
    -- dashboard.section.header.val = {
    --   "                                                      ",
    --   " ███╗   ██╗███████╗ ██████╗ ████████╗███████╗██╗  ██╗ ",
    --   " ████╗  ██║██╔════╝██╔═══██╗╚══██╔══╝██╔════╝╚██╗██╔╝ ",
    --   " ██╔██╗ ██║█████╗  ██║   ██║   ██║   █████╗   ╚███╔╝  ",
    --   " ██║╚██╗██║██╔══╝  ██║   ██║   ██║   ██╔══╝   ██╔██╗  ",
    --   " ██║ ╚████║███████╗╚██████╔╝   ██║   ███████╗██╔╝ ██╗ ",
    --   " ╚═╝  ╚═══╝╚══════╝ ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝ ",
    --   "                                                      ",
    -- }

    -- Set color
    dashboard.section.header.opts.hl = "Title" -- lookup other hl groups with :highlight

    -- für possessions nvim
    vim.api.nvim_create_user_command("AlphaSessions", function()
      -- Telescope possession list (robust, lädt Extension bei Bedarf)
      local ok_telescope, telescope = pcall(require, "telescope")
      if ok_telescope then
        pcall(telescope.load_extension, "possession")
        local ok_ext = pcall(function()
          telescope.extensions.possession.list({})
        end)
        if ok_ext then
          return
        end
      end

      -- Fallback, falls Telescope/Extension nicht verfügbar
      pcall(vim.cmd, "PossessionPick")
    end, {})

    -- Set menu
    dashboard.section.buttons.val = {
      -- dashboard.button("s", "  Sessions", "<cmd>SessionManager load_session<CR>"),
      -- dashboard.button("s", "  Sessions", "<cmd>AlphaSessions<CR>"),
      dashboard.button(
        "s",
        "  Sessions",
        "<cmd>lua require('telescope').extensions.possession.list({ only_cwd = true })<CR>"
      ),
      -- dashboard.button("r", "󰈚  Recent", ":Telescope oldfiles <CR>"),
      dashboard.button("r", "󰈚  Recent", "<cmd>lua require('telescope.builtin').oldfiles({ cwd_only = true })<CR>"), -- nur Dateien aus dem working directory anzeigen
      dashboard.button("e", "󰱼  Explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("f", "  Find", ":Telescope find_files <CR>"),
      -- dashboard.button("t, "Templates", "<leader> t <CR>"),
      dashboard.button("t", "  Templates", ":Telescope find_files cwd=~/.config/nvim/templates<cr>"),
      -- dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
      -- dashboard.button("i", "  Info", "<cmd>e ~/.config/CheatSheet.md<cr>"),
      dashboard.button("p", "  Plugins", ":Telescope find_files cwd=~/.config/nvim/lua/plugins<cr>"),
      dashboard.button("h", "  Checkhealth", "<cmd>checkhealth<cr>"),
      dashboard.button("q", "  Quit", "<cmd>qa!<CR>"),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Set footer
    -- dashboard.section.footer.val = fortune
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

        -- local now = os.date "%d-%m-%Y %H:%M:%S"
        local version = "   v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
        -- local fortune = require "alpha.fortune"
        -- local quote = table.concat(fortune(), "\n")
        local plugins = "⚡Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
        local footer = version .. "\t" .. plugins -- .. "\n" .. quote
        dashboard.section.footer.val = footer
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}

-- JOSEAN Martinez
-- return {
--   "goolord/alpha-nvim",
--   event = "VimEnter",
--   config = function()
--     local alpha = require("alpha")
--     local dashboard = require("alpha.themes.dashboard")

--     -- Set header
--     dashboard.section.header.val = {
--       "                                                     ",
--       "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
--       "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
--       "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
--       "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
--       "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
--       "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
--       "                                                     ",
--     }

--     -- Set menu
--     dashboard.section.buttons.val = {
--       dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
--       dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
--       dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
--       dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
--       dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
--       dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
--     }

--     -- Send config to alpha
--     alpha.setup(dashboard.opts)

--     -- Disable folding on alpha buffer
--     vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
--   end,
-- }
