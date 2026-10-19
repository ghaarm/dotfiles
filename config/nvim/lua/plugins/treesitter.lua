-- https://github.com/Hdoc1509/nvim-config/blob/73f036e77b01aab73a96b53b07d6f66f4d5b83bf/lua/plugins/treesitter/init.lua
-- local config = function()
--   local langs_to_register = require('plugins.treesitter.register')
--   local parsers_to_install = require('plugins.treesitter.ensure-installed')
--   local textobjects = require('plugins.treesitter.textobjects')
--
--   require('nvim-treesitter.install').prefer_git = false
--   require('nvim-treesitter.install').compilers = { 'zig', 'gcc' }
--
--   require('hygen.tree-sitter').setup()
--
--   ---@diagnostic disable-next-line: missing-fields
--   require('nvim-treesitter.configs').setup({
--     ensure_installed = parsers_to_install,
--     highlight = { enable = true },
--     indent = { enable = true },
--     textobjects = textobjects,
--   })
--
--   -- REGISTER LANGUAGES
--   for parser_name, filetype in pairs(langs_to_register) do
--     vim.treesitter.language.register(parser_name, filetype)
--   end
-- end
--
-- return {
--   'nvim-treesitter/nvim-treesitter',
--   build = ':TSUpdate',
--   dependencies = {
--     -- { dir = '~/dev/hygen.nvim' },
--     { 'Hdoc1509/hygen.nvim', tag = 'v0.2.0' },
--     {
--       'JoosepAlviste/nvim-ts-context-commentstring',
--       config = function()
--         ---@diagnostic disable-next-line: missing-fields
--         require('ts_context_commentstring').setup({
--           enable_autocmd = false,
--         })
--       end,
--     },
--     {
--       'windwp/nvim-ts-autotag',
--       config = true,
--       event = { 'BufReadPre', 'BufNewFile' },
--     },
--     'nvim-treesitter/nvim-treesitter-textobjects',
--   },
--   config = config,
--   event = { 'BufReadPre', 'BufNewFile' },
-- }

-- alt before autotag test
-- return {
--   "nvim-treesitter/nvim-treesitter",
--   event = { "BufReadPre", "BufNewFile" },
--   build = ":TSUpdate",
--   dependencies = {
--     "windwp/nvim-ts-autotag",
--   },
--
--   config = function()
--     -- import nvim-treesitter plugin
--     local treesitter = require("nvim-treesitter.configs")
--
--     -- configure treesitter
--     treesitter.setup({ -- enable syntax highlighting
--       highlight = {
--         enable = true,
--       },
--       -- enable indentation
--       indent = { enable = true },
--       -- enable autotagging (w/ nvim-ts-autotag plugin)
--       -- autotag = { -- deactivate because of nvim-ts-autotag 1.0.0
--       --   enable = true,
--       -- },
--       -- ensure these language parsers are installed
--       ensure_installed = {
--         "json",
--         "javascript",
--         "typescript",
--         "tsx",
--         "yaml",
--         "html",
--         "css",
--         "prisma",
--         "markdown",
--         "markdown_inline",
--         "svelte",
--         "graphql",
--         "bash",
--         "lua",
--         "vim",
--         "dockerfile",
--         "gitignore",
--         "query",
--         "vimdoc",
--         "c",
--         "r",
--         "rnoweb",
--       },
--       incremental_selection = {
--         enable = true,
--         keymaps = {
--           init_selection = "<C-space>",
--           node_incremental = "<C-space>",
--           scope_incremental = false,
--           node_decremental = "<bs>",
--         },
--       },
--     })
--   end,
-- }
--
-- wegen nvim 0.12
--
--
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local nts = require("nvim-treesitter")

    nts.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    nts.install({
      "json",
      "javascript",
      "typescript",
      "tsx",
      "yaml",
      "html",
      "css",
      "prisma",
      "markdown",
      "markdown_inline",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "gitignore",
      "query",
      "vimdoc",
      "c",
      "r",
      "rnoweb",
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
      pattern = {
        "json",
        "javascript",
        "typescript",
        "typescriptreact",
        "typst",
        "javascriptreact",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "svelte",
        "graphql",
        "sh",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "c",
        "r",
        "rmd",
        "rnoweb",
      },
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
