return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",

    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    config = function()
      -- Standardmäßige Modusanzeige von Neovim deaktivieren.
      vim.opt.showmode = false

      require("noice").setup({
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          opts = {},
        },

        popupmenu = {
          enabled = true,
          backend = "nui",
          kind_icons = {},
        },

        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },

        presets = {
          bottom_search = false,
          command_palette = false,
          long_message_to_split = false,
          inc_rename = false,
          lsp_doc_border = false,
        },

        routes = {
          {
            view = "notify",
            filter = { event = "msg_showmode" },
          },
        },

        messages = {
          enabled = true,
          view = "mini",
        },
      })

      -- Noice vollständig aktivieren/deaktivieren.
      vim.keymap.set("n", "<leader>nd", function()
        if require("noice.config").is_running() then
          vim.cmd("Noice disable")
        else
          vim.cmd("Noice enable")
        end
      end, {
        desc = "Noice: Toggle",
      })

      -- Noice-History öffnen/schließen.
      vim.keymap.set("n", "<leader>ni", function()
        local history_win = nil

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)

          if vim.bo[buf].filetype == "noice" then
            history_win = win
            break
          end
        end

        if history_win then
          vim.api.nvim_win_close(history_win, true)
        else
          vim.cmd("Noice history")
        end
      end, {
        desc = "Noice: Toggle history",
      })
    end,
  },
}
