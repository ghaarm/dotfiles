-- https://github.com/greggh/claude-code.nvim

return {
  "greggh/claude-code.nvim",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  config = function()
    require("claude-code").setup({

      -- Terminal window settings
      window = {
        split_ratio = 0.3,
        position = "botright",
        enter_insert = true,
        hide_numbers = true,
        hide_signcolumn = true,

        -- Floating window configuration
        float = {
          width = "80%",
          height = "80%",
          row = "center",
          col = "center",
          relative = "editor",
          border = "rounded",
        },
      },

      -- File refresh settings
      refresh = {
        enable = true,
        updatetime = 100,
        timer_interval = 1000,
        show_notifications = true,
      },

      -- Git project settings
      git = {
        use_git_root = true,
      },

      -- Shell-specific settings
      shell = {
        separator = "&&",
        pushd_cmd = "pushd",
        popd_cmd = "popd",
      },

      -- Command settings
      command = "claude",

      -- Command variants
      command_variants = {
        continue = "--continue",
        resume = "--resume",
        verbose = "--verbose",
      },

      -- Keymaps
      keymaps = {
        toggle = {
          normal = "<leader>ca",
          terminal = "<leader>ca",

          variants = {
            continue = "<leader>cC",
            verbose = "<leader>cV",
          },
        },

        window_navigation = true,
        scrolling = true,
      },
    })
  end,
}
