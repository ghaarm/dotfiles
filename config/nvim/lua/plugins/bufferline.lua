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
        local name = tab.name

        -- Bei Oil den aktuellen Ordnernamen anzeigen
        if tab.path:match("^oil://") then
          local path = tab.path:gsub("^oil://", ""):gsub("/$", "")
          name = vim.fn.fnamemodify(path, ":t")
        end

        -- Aktuelle Tabposition bestimmen:
        -- entspricht 1gt, 2gt, ...
        for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
          if tabpage == tab.tabnr then
            return i .. " " .. name
          end
        end

        return name
      end,

      -- Schräge Trennlinien zwischen den Tabs
      separator_style = "slant",
    },
  },
}
