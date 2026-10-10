return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      -- Neovim-Tabs statt einzelner Buffer anzeigen
      mode = "tabs",

      -- Tabnummer in den Namen integrieren, damit die Darstellung
      -- Icon → Nummer → Dateiname ist.
      -- Die Nummer entspricht der Tabnummer für 1gt, 2gt, ...
      numbers = "none",
      name_formatter = function(tab)
        return tab.tabnr .. " " .. tab.name
      end,

      -- Schräge Trennlinien zwischen den Tabs
      separator_style = "slant",
    },
  },
}
