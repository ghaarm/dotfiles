
-- https://github.com/chomosuke/typst-preview.nvim
return {
  "chomosuke/typst-preview.nvim",
  version = "1.*",
  ft = "typst",
  cmd = {
    "TypstPreview",
    "TypstPreviewStop",
    "TypstPreviewToggle",
    "TypstPreviewUpdate",
    "TypstPreviewSyncCursor",
    "TypstPreviewFollowCursor",
    "TypstPreviewNoFollowCursor",
    "TypstPreviewFollowCursorToggle",
  },

  opts = {
    debug = false, -- Log: stdpath('data')/typst-preview/log.txt
    open_cmd = "open -a Zen %s", -- Vorschau immer in Zen öffnen
    port = 0, -- freien Port automatisch wählen
    host = "127.0.0.1", -- Vorschau nur lokal bereitstellen
    invert_colors = "never", -- mögliche Werte: never, always, auto
    partial_rendering = true, -- bei großen Dokumenten nur den sichtbaren Bereich rendern
    follow_cursor = false, -- kein automatisches Scrollen bei Cursorbewegungen

    -- Ohne Pfade lädt das Plugin passende Versionen bei setup() selbst herunter.
    -- Falls lokale Binaries verwendet werden sollen, hier tinymist und websocat eintragen.
    dependencies_bin = {},

    -- Zusätzliche Previewer-Argumente, z. B. { "--input=ver=draft" }.
    extra_args = nil,

    get_root = function(path_of_main_file)
      local root = os.getenv("TYPST_ROOT")
      if root and root ~= "" then
        return root
      end

      local main_dir = vim.fs.dirname(vim.fn.fnamemodify(path_of_main_file, ":p"))
      local found = vim.fs.find({ "typst.toml", ".git" }, { path = main_dir, upward = true })
      return #found > 0 and vim.fs.dirname(found[1]) or main_dir
    end,

    -- Für Projekte mit einer separaten Hauptdatei kann diese Funktion angepasst werden.
    get_main_file = function(path_of_buffer)
      return path_of_buffer
    end,
  },

  config = function(_, opts)
    require("typst-preview").setup(opts)

    local function set_typst_maps(buf)
      vim.keymap.set("n", "<localleader>vp", "<cmd>TypstPreviewToggle<CR>", {
        buffer = buf,
        silent = true,
        desc = "Typst-Vorschau umschalten",
      })
      vim.keymap.set("n", "<localleader>vs", "<cmd>TypstPreviewStop<CR>", {
        buffer = buf,
        silent = true,
        desc = "Typst-Vorschau stoppen",
      })
      vim.keymap.set("n", "<localleader>vl", "<cmd>TypstPreviewSyncCursor<CR>", {
        buffer = buf,
        silent = true,
        desc = "Typst-Vorschau zur Cursorposition bewegen",
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "typst",
      callback = function(args)
        set_typst_maps(args.buf)
      end,
    })

    -- Beim Laden über ft ist das FileType-Ereignis für den aktuellen Buffer schon gelaufen.
    if vim.bo.filetype == "typst" then
      set_typst_maps(vim.api.nvim_get_current_buf())
    end
  end,
}
