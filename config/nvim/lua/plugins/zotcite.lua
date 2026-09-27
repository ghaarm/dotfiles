-- TSInstall yaml sollte installiert sein, geht nicht über Mason

return {
  "jalvesaq/zotcite",

  -- Bereits das Laden begrenzen: Zotcite initialisiert die Datenbank,
  -- bevor es seine eigene filetypes-Einstellung prüft.
  ft = { "markdown", "pandoc" },

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
  },

  config = function()
    require("zotcite").setup({
      -- Deine Better-BibTeX Citation Keys verwenden
      key_type = "better-bibtex",

      -- Nur für Markdown/Pandoc aktivieren.
      -- Dein bestehendes LaTeX/cmp-vimtex bleibt damit unangetastet.
      filetypes = {
        "markdown",
        "pandoc",
      },

      -- Normaler Zotero-Datenordner unter macOS
      zotero_sqlite_path = vim.fn.expand("~/Zotero/zotero.sqlite"),

      -- PDF mit dem normalen System-PDF-Viewer öffnen
      open_in_zotero = false,
    })
  end,
}
