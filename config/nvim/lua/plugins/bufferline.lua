return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      -- Neovim-Tabs statt einzelner Buffer anzeigen
      mode = "tabs",

      -- Eingebaute Nummerierung deaktivieren, da sie vor dem Icon
      -- dargestellt wird.
      numbers = "none",

      -- Aktuelle Tabposition in den Namen integrieren:
      -- Icon → Nummer → Dateiname.
      -- Die Nummer entspricht der Position für 1gt, 2gt, ...
      name_formatter = function(tab)
        for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
          if tabpage == tab.tabnr then
            return i .. " " .. tab.name
          end
        end
        return tab.name
      end,

      -- Schräge Trennlinien zwischen den Tabs
      separator_style = "slant",
    },
  },
}
