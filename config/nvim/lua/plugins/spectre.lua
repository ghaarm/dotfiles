-- -- https://github.com/nvim-pack/nvim-spectre
--
-- return {
--   "nvim-pack/nvim-spectre",
--   config = function()
--     -- Setup Spectre
--     require("spectre").setup()
--
--     -- Key mappings for Spectre
--     vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
--       desc = "Toggle Spectre",
--     })
--     vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
--       desc = "Search current word",
--     })
--     vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
--       desc = "Search current word",
--     })
--     vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
--       desc = "Search in current file",
--     })
--
--     -- Utilizing Spectre actions
--     local spectre_actions = require("spectre.actions")
--     -- Get the current entry from Spectre
--     local current_entry = spectre_actions.get_current_entry()
--     -- Get all entries from Spectre
--     local all_entries = spectre_actions.get_all_entries()
--     -- Get the state from Spectre
--     local spectre_state = spectre_actions.get_state()
--
--     -- (Optional) You can add code here to use the retrieved data, e.g., logging or further processing
--     -- print("Current Entry:", current_entry)
--     -- print("All Entries:", all_entries)
--     -- p:w
--     -- rint("Spectre State:", spectre_state)
--   end,
-- }
--
--
--
-- https://github.com/nvim-pack/nvim-spectre

return {
  "nvim-pack/nvim-spectre",
  config = function()
    -- Setup Spectre
    local spectre = require("spectre")
    spectre.setup({
      replace_engine = {
        ["sd"] = { cmd = "sd", options = {} },
      },
      default = {
        replace = { cmd = "sd" },
      },
    })
    vim.keymap.set("n", "<leader>sP", function()
      spectre.toggle()
    end, { desc = "Spectre umschalten" })

    -- -- Key mappings for Spectre
    -- vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
    --   desc = "Toggle Spectre",
    -- })
    -- vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    --   desc = "Search current word",
    -- })
    -- vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    --   desc = "Search current word",
    -- })
    -- vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    --   desc = "Search in current file",
    -- })
    --
    -- -- Utilizing Spectre actions
    -- local spectre_actions = require("spectre.actions")
    -- -- Get the current entry from Spectre
    -- local current_entry = spectre_actions.get_current_entry()
    -- -- Get all entries from Spectre
    -- local all_entries = spectre_actions.get_all_entries()
    -- -- Get the state from Spectre
    -- local spectre_state = spectre_actions.get_state()

    -- (Optional) You can add code here to use the retrieved data, e.g., logging or further processing
    -- print("Current Entry:", current_entry)
    -- print("All Entries:", all_entries)
    -- p:w
    -- rint("Spectre State:", spectre_state)
  end,
}
