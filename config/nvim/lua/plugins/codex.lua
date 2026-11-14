-- https://github.com/johnseth97/codex.nvim
--
return {
  "johnseth97/codex.nvim",
  lazy = true,
  cmd = { "Codex", "CodexToggle" },
  keys = {
    {
      "<leader>cd",
      function()
        require("codex").toggle()
      end,
      desc = "Toggle Codex (popup/panel)",
      mode = { "n", "t" },
    },
  },
  opts = {
    keymaps = {
      toggle = nil, -- internal toggle mapping AUS
      quit = "<C-q>", -- quit mapping bleibt
    },
    border = "rounded",
    width = 0.8,
    height = 0.8,
    model = nil,
    autoinstall = false,
    panel = false,
    use_buffer = false,
  },
}
