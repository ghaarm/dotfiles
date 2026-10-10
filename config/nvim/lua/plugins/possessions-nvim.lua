return {
  "jedrzejboczar/possession.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("possession").setup({
      -- Für deine Situation (teils mehrere Projekte im gleichen Ordner):
      -- eher NICHT blind nach CWD autoloaden, sondern gezielt per Picker laden.
      autoload = false,

      autosave = {
        current = true, -- speichert die aktuell geladene Session beim Beenden/Wechsel
        on_load = true,
        on_quit = true,
      },
      plugins = {
        delete_hidden_buffers = {
          -- WICHTIG: nicht vor dem Speichern löschen, sonst verschwinden "hidden" Dateien aus der Session
          hooks = { "before_load" },

          -- Terminal-Buffers beim Aufräumen force-deleten, damit E89 nicht blockiert
          force = function(bufnr)
            return vim.bo[bufnr].buftype == "terminal"
          end,
        },
      },
      telescope = {
        list = {
          mappings = {
            delete = { i = "dd", n = "dd" }, -- Insert: Ctrl-d, Normal: dd
          },
        },
      },
      -- hooks = {
      --   before_load = function(_, user_data)
      --     return user_data
      --   end,
      --   after_load = function()
      --     vim.schedule(function()
      --       pcall(vim.cmd, "redrawstatus")
      --     end)
      --   end,
      --   after_save = function()
      --     vim.schedule(function()
      --       pcall(vim.cmd, "redrawstatus")
      --     end)
      --   end,
      -- },
      hooks = {
        before_load = function(_, user_data)
          return user_data
        end,

        -- Neovims mksession stellt Oil-Buffer nicht vollständig wieder her:
        -- Die oil://-Buffer werden zwar mit ihrem Namen angelegt, aber nicht
        -- durch Oil initialisiert und erscheinen deshalb nach dem Laden einer
        -- Possession-Session leer.
        --
        -- Nach dem Laden der Session werden daher alle oil://-Buffer gesucht
        -- und mit Oils eigener load_oil_buffer()-Funktion initialisiert.
        after_load = function()
          vim.schedule(function()
            local oil = require("oil")

            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_valid(buf) then
                local name = vim.api.nvim_buf_get_name(buf)

                if name:match("^oil://") then
                  oil.load_oil_buffer(buf)
                end
              end
            end

            pcall(vim.cmd, "redrawstatus")
          end)
        end,

        after_save = function()
          vim.schedule(function()
            pcall(vim.cmd, "redrawstatus")
          end)
        end,
      },
    })

    -- Telescope Extension aktivieren :contentReference[oaicite:0]{index=0}
    -- require("telescope").load_extension("possession")

    -- Keymaps (Leader = Space)
    local telescope_possession = function(opts)
      require("telescope").extensions.possession.list(opts or {})
    end

    vim.keymap.set("n", "<leader>sa", function()
      telescope_possession()
    end, { desc = "Sessions: All (Telescope)" })

    vim.keymap.set("n", "<leader>sp", function()
      telescope_possession({ only_cwd = true })
    end, { desc = "Sessions: this CWD (Telescope)" })

    vim.keymap.set("n", "<leader>sS", "<cmd>PossessionSave<cr>", { desc = "Session speichern" })
    vim.keymap.set("n", "<leader>sr", "<cmd>PossessionRename<cr>", { desc = "Session umbenennen" })
    vim.keymap.set("n", "<leader>sd", "<cmd>PossessionDelete<cr>", { desc = "Session löschen" })
  end,
}
