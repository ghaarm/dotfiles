-- return {
--   "williamboman/mason.nvim",
--   dependencies = {
--     "williamboman/mason-lspconfig.nvim",
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--   },
--   config = function()
--     -- import mason
--     local mason = require("plugins.mason")
--
--     -- import mason-lspconfig
--     local mason_lspconfig = require("mason-lspconfig")
--
--     local mason_tool_installer = require("mason-tool-installer")
--
--     -- enable mason and configure icons
--     mason.setup({
--       ui = {
--         icons = {
--           package_installed = "✓",
--           package_pending = "➜",
--           package_uninstalled = "✗",
--         },
--       },
--     })
--
--     mason_lspconfig.setup({
--       -- list of servers for mason to install
--       ensure_installed = {
--         -- Webentwicklung
--
--         -- "tsserver",
--         "ts_ls",
--         "html",
--         "cssls",
--         "tailwindcss",
--         "svelte",
--         "graphql",
--         "emmet_ls",
--         "prismals",
--         -- Lua
--         "lua_ls",
--         -- Python
--         "pyright",
--         -- R
--         "r_language_server",
--         -- LaTeX
--         "texlab",
--         -- Markdown
--         "marksman",
--       },
--       -- Mit aktuellem mason-lspconfig werden installierte Server
--
--       -- über vim.lsp.enable() automatisch aktiviert.
--
--       automatic_enable = true,
--     })
--
--     mason_tool_installer.setup({
--       ensure_installed = {
--         -- Web / Markdown
--         "prettier",
--         "eslint_d",
--         "markdownlint-cli2",
--         -- Lua
--         "stylua",
--         -- Python
--         "isort",
--         "black",
--         "pylint",
--         -- LaTeX
--         "latexindent",
--       },
--       run_on_start = true,
--       start_delay = 3000,
--       debounce_hours = 24,
--     })
--   end,
-- }
return {
  {
    "mason-org/mason.nvim",
    lazy = false,

    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",

    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },

    opts = {
      ensure_installed = {
        -- Web
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "graphql",
        "emmet_ls",
        "prismals",

        -- Lua
        "lua_ls",

        -- Python
        "pyright",

        -- R
        "r_language_server",

        -- LaTeX
        "texlab",

        -- Markdown
        "marksman",
        -- Typst
        "tinymist",

        -- YAML
        "yamlls",
      },

      automatic_enable = true,
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    dependencies = {
      "mason-org/mason.nvim",
    },

    opts = {
      ensure_installed = {
        "prettier",
        "eslint_d",
        "markdownlint-cli2",
        "stylua",
        "isort",
        "black",
        "pylint",
        "latexindent",
      },

      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 24,
    },
  },
}
