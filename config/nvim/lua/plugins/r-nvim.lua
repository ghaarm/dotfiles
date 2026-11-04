-- um pdfviewer zu setzen https://github.com/R-nvim/R.nvim/issues/112

vim.g.R_filetypes = { "r", "rmd", "rnoweb" }

vim.api.nvim_set_keymap("t", "jj", [[<C-\><C-n>]], { noremap = true, silent = true })

return {
  {
    "R-nvim/R.nvim",
    lazy = false,
    -- submodules = true,
    config = function()
      -- Setzen der Sprachumgebung für R
      vim.cmd("let $LANG = 'en_US.UTF-8'")
      vim.cmd("let $LANGUAGE = 'en_US.UTF-8'")
      -- Create a table with the options to be passed to setup()
      local opts = {
        R_args = {
          -- "--quiet",
          "--no-save",
        },
        hook = {
          on_filetype = function()
            -- This function will be called at the FileType event
            -- of files supported by R.nvim. This is an
            -- opportunity to create mappings local to buffers.
            vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
            vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
          end,
        },
        min_editor_width = 72,
        rconsole_width = 78,
        disable_cmds = {
          "RClearConsole",
          "RCustomStart",
          "RSPlot",
          "RSaveClose",
        },
        pdfviewer = "Sioyek",
      }

      -- Check if the environment variable "R_AUTO_START" exists.
      -- If using fish shell, you could put in your config.fish:
      -- alias r "R_AUTO_START=true nvim"
      if vim.env.R_AUTO_START == "true" then
        opts.auto_start = 1
        opts.objbr_auto_start = true
      end

      require("r").setup(opts)

      -- https://github.com/R-nvim/R.nvim/blob/main/doc/R.nvim.txt
      -- macht die Farben so wie in meinem eingestellten colorscheme, andere varianten auf der Homepage
      vim.g.rout_follow_colorscheme = true

      -- Funktion um nach dem Knitten in R automatisch die geknittete HTML im Browser zu öffnen
      local function knit_and_open()
        -- Run the KnitRhtml command
        vim.cmd("KnitRhtml")
        -- Get the name of the resulting HTML file
        local filename = vim.fn.expand("%:p:r") .. ".html"
        -- Escape special characters in the filename for shell command
        local escaped_filename = vim.fn.shellescape(filename)
        -- Open the HTML file in the default web browser
        os.execute("open " .. escaped_filename)
      end

      -- Create a custom command KnitRhtmlAndOpen that knits the file and opens it
      vim.api.nvim_create_user_command("KnitRhtmlAndOpen", knit_and_open, {})
    end, -- Ende der config = function
  },
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "markdown", "markdown_inline", "r", "rnoweb" },
      })
    end,
  },
  -- "R-nvim/cmp-r", -- no longer needed after major update 2026-02-08
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require("cmp").setup({
        sources = {
          -- { name = "cmp_r" },
        },
      })
      -- require("cmp_r").setup({})
    end,
  },
  -- vim.api.nvim_set_keymap("t", "jj", [[<C-\><C-n>]], { noremap = true, silent = true }),
}
