vim.g.maplocalleader = ","

return {
  "iamcco/markdown-preview.nvim",
  lazy = true, -- Lädt das Plugin nur, wenn es benötigt wird
  ft = { "md", "markdown" }, -- Lädt das Plugin nur für LaTeX-Dateien
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  -- ft = { "markdown" },
  config = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_command_for_global = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = ""
    vim.g.mkdp_browser = ""
    vim.g.mkdp_echo_preview_url = 0
    vim.g.mkdp_browserfunc = ""
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {},
    }
    vim.g.mkdp_markdown_css = ""
    vim.g.mkdp_highlight_css = ""
    vim.g.mkdp_port = ""
    vim.g.mkdp_page_title = "「${name}」"
    -- vim.g.mkdp_images_path = '/home/user/.markdown_images'
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_theme = "dark"
    vim.g.mkdp_combine_preview = 0
    vim.g.mkdp_combine_preview_auto_refresh = 1

    -- Setze Keybindings für Markdown Preview

    vim.keymap.set(
      "n",
      "<localleader>ll",
      ":MarkdownPreview<CR>",
      { noremap = true, silent = true, desc = "Markdown Preview" }
    )
    -- vim.keymap.set(
    --   "n",
    --   "<localleader>lu",
    --   ":MarkdownPreview<CR>",
    --   { noremap = true, silent = true, desc = "Markdown Preview" }
    -- )
    vim.keymap.set(
      "n",
      "<localleader>mu",
      ":MarkdownPreviewToggle<CR>",
      { noremap = true, silent = true, desc = "Toggle Markdown Preview" }
    )
    vim.keymap.set(
      "n",
      "<localleader>mt",
      ":MarkdownPreviewToggle<CR>",
      { noremap = true, silent = true, desc = "Toggle Markdown Preview" }
    )

    vim.keymap.set(
      "n",
      "<localleader>ms",
      ":MarkdownPreviewStop<CR>",
      { noremap = true, silent = true, desc = "Markdown Preview Stop" }
    )
  end,
}
