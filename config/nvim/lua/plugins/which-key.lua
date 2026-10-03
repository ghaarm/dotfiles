return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    -- defaults = {
    --   preset = "classic",
    --   notify = true,
    --   plugins = {
    --     marks = true,     -- shows a list of your marks on ' and `
    --     registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    --     -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    --     -- No actual key bindings are created
    --     spelling = {
    --       enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
    --       suggestions = 20, -- how many suggestions should be shown in the list?
    --     },
    --     presets = {
    --       operators = false,    -- adds help for operators like d, y, ...
    --       motions = false,      -- adds help for motions
    --       text_objects = false, -- help for text objects triggered after entering an operator
    --       windows = false,      -- default bindings on <c-w>
    --       nav = false,          -- misc bindings to work with windows
    --       z = false,            -- bindings for folds, spelling and others prefixed with z
    --       g = false,            -- bindings for prefixed with g
    --     },
    --   },
    -- },
  },
  -- keys = {
  --   {
  --     "<leader>?",
  --     function()
  --       require("which-key").show({ global = false })
  --     end,
  --     desc = "Buffer Local Keymaps (which-key)",
  --   },
  -- },
  config = function(_, opts)
    local wk = require("which-key")
    wk.add({
      {
        "<leader>t",
        group = "TEMPLATES",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tta",
        "<cmd>read ~/.config/nvim/templates/article-template.tex<CR>",
        desc = "article-template.tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttb",
        "<cmd>read ~/.config/nvim/templates/article-template-knn.tex<CR>",
        desc = "article-template-knn.tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttt",
        "<cmd>read ~/.config/nvim/templates/article-template-toc.tex<CR>",
        desc = "article-template-toc.tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttc",
        "<cmd>read ~/.config/nvim/templates/footer-footnotes-bibliography.tex<CR>",
        desc = "footer-footnotes-bibliography.tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tte",
        function()
          vim.cmd.tabedit(
            vim.fn.fnameescape(vim.fn.expand("~/.config/nvim/templates/footer-footnotes-bibliography.tex"))
          )
        end,
        desc = "footer-footnotes-bibliography.tex EDIT",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttd",
        "<cmd>read ~/.config/nvim/templates/footer-footnotes-bibliography-knn.tex<CR>",
        desc = "footer-footnotes-bibliography-knn.tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttg",
        "<cmd>read ~/.config/nvim/templates/chapter.tex<CR>",
        desc = "chapter template tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttp",
        function()
          vim.cmd.tabedit(
            vim.fn.fnameescape(
              "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/R Statistik, icloud/Latex, icloud/Latex Projekte/@Vorlagen-Latex/preamble-footnotes-bibliographie-neu.tex"
            )
          )
        end,
        desc = "Präambel Footnotes Bibliography EDIT",
        nowait = true,
        remap = false,
      },
      -- Beamer Präambel
      {
        "<leader>tbp",
        function()
          vim.cmd.tabedit(
            vim.fn.fnameescape(
              "/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/R Statistik, icloud/Latex, icloud/Latex Projekte/icu-latex/beamer-latex-icu/beamer-templates/kn-beamer-preamble.tex"
            )
          )
        end,
        desc = "Beamer Präambel KN EDIT",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tby",
        function()
          vim.cmd.tabedit(vim.fn.fnameescape("~/.config/nvim/templates/beamer-vorlage-knn.tex"))
        end,
        desc = "Beamer Vorlage KN EDIT",
        nowait = true,
        remap = false,
      },
      -- Beamer Templates
      {
        "<leader>tbk",
        "<cmd>read ~/.config/nvim/templates/beamer-vorlage-knn.tex<CR>",
        desc = "Beamer KN template tex",
        nowait = true,
        remap = false,
      },

      -- andere Templates
      {
        "<leader>th",
        "<cmd>read ~/.config/nvim/templates/template.html<CR>",
        desc = "html template tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttm",
        "<cmd>read ~/.config/nvim/templates/briefkopf-vorlage-latex-2026-04-10-med.tex<CR>",
        desc = "Briefkopf med",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tti",
        "<cmd>read ~/.config/nvim/templates/briefkopf-vorlage-latex-2026-04-10-no-med.tex<CR>",
        desc = "Briefkopf NO med",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttl",
        "<cmd>read ~/.config/nvim/templates/footer-footnotes.tex<CR>",
        desc = "footer-footnotes.tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tt1",
        "<cmd>read ~/.config/nvim/templates/mail.txt<CR>",
        desc = "mail.txt",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tmm",
        "<cmd>read ~/.config/nvim/templates/markdown.md<CR>",
        desc = "markdown.md",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tmp",
        "<cmd>read ~/.config/nvim/templates/project-md-template.md<CR>",
        desc = "project.md",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttn",
        "<cmd>read ~/.config/nvim/templates/book.tex<CR>",
        desc = "report template tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>tts",
        "<cmd>read ~/.config/nvim/templates/cheat-sheet.md<CR>",
        desc = "cheat-sheet.md",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttu",
        "<cmd>read ~/.config/nvim/templates/übergabeprotokoll.tex<CR>",
        desc = "übergabeprotokoll.tex",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ttv",
        "<cmd>tabedit ~/.config/nvim/templates/vim-keys.md<CR>",
        desc = "vim-keys",
        nowait = true,
        remap = false,
      },
      {
        "<leader>ss",
        "<cmd>setlocal spell!<CR>",
        desc = "Spell toggle",
        nowait = true,
        remap = false,
      },
      -- { "<leader>p", group = " " },
      -- leader leader Gruppe
      { "<leader><leader>", group = "quick" }, -- macht den Prefix sichtbar
      { "<leader><leader>x", desc = "Source current file" },
    })
    -- wk.setup(opts.setup)
    -- wk.register(opts.defaults)
  end,
}
