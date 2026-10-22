-- return {
--   "neovim/nvim-lspconfig",
--   event = { "BufReadPre", "BufNewFile" },
--   dependencies = {
--     { "hrsh7th/cmp-nvim-lsp" },
--     { "antosha417/nvim-lsp-file-operations", config = true },
--   },
--   config = function()
--     -- import lspconfig plugin
--     local lspconfig = require("lspconfig")
--
--     -- import cmp-nvim-lsp plugin
--     local cmp_nvim_lsp = require("cmp_nvim_lsp")
--
--     -- used to enable autocompletion (assign to every lsp server config)
--     local default = cmp_nvim_lsp.default_capabilities()
--
--     -- Change the Diagnostic symbols in the sign column (gutter)
--     local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
--     for type, icon in pairs(signs) do
--       local hl = "DiagnosticSign" .. type
--       vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
--     end
--
--     -- -- configure html server
--     -- lspconfig["html"].setup({
--     --   capabilities = default,
--     -- })
--
--     -- -- configure typescript server with plugin
--     -- lspconfig["tsserver"].setup({
--     --   capabilities = default,
--     -- })
--
--     -- -- configure emmet language server
--     -- lspconfig["emmet_ls"].setup({
--     --   capabilities = default,
--     --   filetypes = { "html", "typescriptreact", "javascriptreact" }, -- , "css", "sass", "scss", "less", "svelte"
--     -- })
--
--     -- configure python server
--     lspconfig["pyright"].setup({
--       capabilities = default,
--     })
--
--     -- configure lua server (with special settings)
--     lspconfig["lua_ls"].setup({
--       capabilities = default,
--       settings = {
--         -- custom settings for lua
--         Lua = {
--           -- make the language server recognize "vim" global
--           diagnostics = {
--             globals = { "vim" },
--           },
--           workspace = {
--             -- make language server aware of runtime files
--             library = {
--               [vim.fn.expand("$VIMRUNTIME/lua")] = true,
--               [vim.fn.stdpath("config") .. "/lua"] = true,
--             },
--           },
--         },
--       },
--     })
--     -- configure texlab (LaTeX LSP)
--     lspconfig["texlab"].setup({
--       capabilities = default,
--       settings = {
--         texlab = {
--           build = {
--             executable = "latexmk",
--             args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
--             onSave = true, -- Automatisches Bauen beim Speichern
--           },
--           forwardSearch = {
--             executable = "zathura", -- Falls du Zathura als PDF-Viewer nutzt
--             args = { "--synctex-forward", "%l:1:%f", "%p" },
--           },
--           chktex = {
--             onEdit = true,
--             onOpenAndSave = true,
--           },
--           latexFormatter = "latexindent",
--           latexindent = {
--             modifyLineBreaks = true,
--           },
--         },
--       },
--     })
--   end,
-- }
--
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- cmp capabilities
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local default_caps = cmp_nvim_lsp.default_capabilities()

    -- (optional) gemeinsames on_attach
    local on_attach = function(client, bufnr)
      -- deine Keymaps etc.
      -- Beispiel:
      -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
    end

    -- Globale Defaults für ALLE Server setzen (werden gemerged)
    vim.lsp.config("*", {
      capabilities = default_caps,
      on_attach = on_attach,
    })

    ----------------------------------------------------------------------
    -- Server-spezifische Konfigurationen
    ----------------------------------------------------------------------

    -- Pyright
    vim.lsp.config("pyright", {
      -- zusätzliche pyright-Settings hier bei Bedarf
    })
    vim.lsp.enable("pyright")

    -- Lua (lua_ls)
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- Texlab (LaTeX)
    vim.lsp.config("texlab", {
      settings = {
        texlab = {
          build = {
            executable = "latexmk",
            args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
            onSave = true,
          },
          forwardSearch = {
            executable = "zathura",
            args = { "--synctex-forward", "%l:1:%f", "%p" },
          },
          chktex = {
            onEdit = true,
            onOpenAndSave = true,
          },
          latexFormatter = "latexindent",
          latexindent = {
            modifyLineBreaks = true,
          },
        },
      },
    })
    vim.lsp.enable("texlab")
    -- Tinymist (Typst)
    vim.lsp.config("tinymist", {
      settings = {
        rootPath = "/",
      },
    })
    vim.lsp.enable("tinymist")
    ----------------------------------------------------------------------
    -- Beispiel (deaktiviert) – so würdest du weitere Server migrieren:
    ----------------------------------------------------------------------
    -- HTML
    vim.lsp.config("html", {
      filetypes = {
        "html",
        "xhtml",
        "r",
        "rmd",
        "rmarkdown",
      },
    })
    vim.lsp.enable("html")
    -- XML / CSL
    vim.lsp.config("lemminx", {
      filetypes = { "xml" },
    })
    vim.lsp.enable("lemminx")
    -- TypeScript
    -- vim.lsp.config("tsserver", {})
    -- vim.lsp.enable("tsserver")

    -- Emmet
    -- vim.lsp.config("emmet_ls", {
    --   filetypes = { "html", "typescriptreact", "javascriptreact" },
    -- })
    -- vim.lsp.enable("emmet_ls")
  end,
}
