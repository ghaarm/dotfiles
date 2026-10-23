return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- Füge hier Optionen hinzu, falls gewünscht
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify", -- Optional
    },
    config = function()
      -- sollte eigentlich die Dauer der Messages zb für Autosave verkürzen, funktioniert aber nicht
      require("notify").setup({
        timeout = 1000,
      })
      -- Deaktiviere die standardmäßige Modusanzeige von Vim
      vim.opt.showmode = false

      -- local noice_notify_enabled = true
      --
      --
      -- function ToggleNoiceNotify()
      --   noice_notify_enabled = not noice_notify_enabled
      --   require("noice").setup({
      --     notify = {
      --       enabled = noice_notify_enabled,
      --     },
      --   })
      --   if noice_notify_enabled then
      --     print("Noice notifications enabled")
      --   else
      --     print("Noice notifications disabled")
      --   end
      -- end
      --
      -- -- Keymap zum Umschalten der Benachrichtigungen
      -- vim.keymap.set("n", "<leader>tn", function()
      --   ToggleNoiceNotify()
      -- end, { desc = "Toggle Noice notifications" })
      local noice_enabled = true

      vim.keymap.set("n", "<leader>nd", function()
        noice_enabled = not noice_enabled

        if noice_enabled then
          vim.cmd("Noice enable")
        else
          vim.cmd("Noice disable")
        end
      end, {
        desc = "Noice: Toggle",
      })
      require("noice").setup({
        cmdline = {
          enabled = true, -- enables the Noice cmdline UI
          view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
          opts = {}, -- global options for the cmdline. See section on views
        },
        popupmenu = {
          enabled = true, -- enables the Noice popupmenu UI
          backend = "nui", -- backend to use to show regular cmdline completions
          kind_icons = {}, -- set to `false` to disable icons
        },
        lsp = {
          -- Überschreibt das Markdown-Rendering, damit **cmp** und andere Plugins **Treesitter** verwenden
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- benötigt hrsh7th/nvim-cmp
          },
        },
        -- Du kannst ein Preset für eine einfachere Konfiguration aktivieren
        presets = {
          bottom_search = false, -- verwendet eine klassische untere Befehlszeile für die Suche
          command_palette = false, -- positioniert die Befehlszeile und das Popup-Menü zusammen
          long_message_to_split = false, -- lange Nachrichten werden in einem Split-Fenster angezeigt
          inc_rename = false, -- aktiviert einen Eingabedialog für inc-rename.nvim
          lsp_doc_border = false, -- fügt einen Rahmen zu Hover-Dokumenten und Signaturhilfe hinzu
        },
        routes = {
          {
            view = "notify",
            filter = { event = "msg_showmode" },
          },
          -- {
          --   filter = {
          --     event = "msg_show",
          --     kind = "echomsg",
          --     find = "INSERT",
          --   },
          --   opts = { skip = true },
          -- },
        },
        messages = {
          enabled = true, -- Deaktiviere dies, wenn `cleaning_interval` von autosave funktionieren soll
          -- view = "notify", -- Ändere dies zu "notify" oder mini, falls `MsgArea` überschrieben wird, auto save wird damit unten rechts angezeigt
          view = "mini", -- Ändere dies zu "notify" oder mini, falls `MsgArea` überschrieben wird, auto save wird damit unten rechts angezeigt
        },
      })
    end,
  },
}
--
