-- return {
--   "ThePrimeagen/harpoon",
--   lazy = false,
--   branch = "harpoon2",
--   init = function()
--     local harpoon = require("harpoon")
--
--     -- REQUIRED
--     harpoon:setup({
--       global_settings = {
--         save_on_toggle = true,
--         save_on_change = true,
--       },
--     })
--     -- REQUIRED
--
--     -- vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,  { noremap = true, desc = "add file to harpoon" })
--     -- vim.keymap.set("n", "<D-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { noremap = true, desc = "toggle harpoon" })
--
--     vim.keymap.set("n", "<leader>ha", function()
--       harpoon:list():add()
--     end, { noremap = true, desc = "add file to harpoon" })
--     vim.keymap.set("n", "<leader>ht", function()
--       harpoon.ui:toggle_quick_menu(harpoon:list())
--     end, { noremap = true, desc = "toggle harpoon" })
--
--     vim.keymap.set("n", "<C-h>", function()
--       harpoon:list():select(1)
--     end)
--     vim.keymap.set("n", "<C-t>", function()
--       harpoon:list():select(2)
--     end)
--     vim.keymap.set("n", "<C-n>", function()
--       harpoon:list():select(3)
--     end)
--     vim.keymap.set("n", "<C-s>", function()
--       harpoon:list():select(4)
--     end)
--
--     -- Toggle previous & next buffers stored within Harpoon list
--     vim.keymap.set("n", "<C-S-P>", function()
--       harpoon:list():prev()
--     end, { noremap = true, desc = "prev buffer" })
--     vim.keymap.set("n", "<C-S-N>", function()
--       harpoon:list():next()
--     end)
--   end,
--   dependencies = { "nvim-lua/plenary.nvim" },
-- }
--
return {
  "ThePrimeagen/harpoon",
  lazy = false,
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },

  init = function()
    local harpoon = require("harpoon")

    local function detect_project_root()
      local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      if vim.v.shell_error == 0 and git_root ~= "" then
        return git_root
      end
      return vim.fn.getcwd()
    end

    local function get_harpoon_root()
      if vim.t.harpoon_root and vim.t.harpoon_root ~= "" then
        return vim.t.harpoon_root
      end
      vim.t.harpoon_root = detect_project_root()
      return vim.t.harpoon_root
    end

    local function set_harpoon_root(root)
      vim.t.harpoon_root = vim.fn.fnamemodify(root, ":p")
      vim.notify("Harpoon root: " .. vim.t.harpoon_root)
    end

    harpoon:setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
          return get_harpoon_root()
        end,
      },

      default = {
        get_root_dir = function()
          return get_harpoon_root()
        end,

        create_list_item = function(config, _)
          local file = vim.api.nvim_buf_get_name(0)
          if file == "" then
            return nil
          end

          local root = config.get_root_dir()

          return {
            value = vim.fn.fnamemodify(file, ":p"),
            context = {
              row = vim.api.nvim_win_get_cursor(0)[1],
              col = vim.api.nvim_win_get_cursor(0)[2],
              name = vim.fn.fnamemodify(file, ":t"),
              root = root,
            },
          }
        end,

        select = function(list_item, _, _)
          if not list_item or not list_item.value or list_item.value == "" then
            vim.notify("Leerer Harpoon-Eintrag", vim.log.levels.WARN)
            return
          end

          vim.cmd.edit(vim.fn.fnameescape(vim.fn.fnamemodify(list_item.value, ":p")))
        end,

        display = function(item)
          return item.value
        end,
      },
    })

    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "add file to harpoon" })

    vim.keymap.set("n", "<leader>ht", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "toggle harpoon" })

    vim.keymap.set("n", "<leader>hr", function()
      set_harpoon_root(vim.fn.getcwd())
    end, { desc = "set harpoon root to cwd" })

    for i = 6, 9 do
      vim.keymap.set("n", "<leader>" .. i, function()
        harpoon:list():select(i)
      end, { desc = "Harpoon " .. i })
    end
  end,
}
