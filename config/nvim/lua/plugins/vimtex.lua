-- https://github.com/lervag/vimtex

vim.g.maplocalleader = ","

return {
  "lervag/vimtex",
  -- dependencies = {
  --   "xuhdev/vim-latex-live-preview",
  -- },
  lazy = false, -- soll nicht true sein weil sonst inverse search nicht geht Lädt das Plugin nur, wenn es benötigt wird
  -- ft = { "tex" }, -- Lädt das Plugin nur für LaTeX-Dateien
  config = function()
    -- Lokale Funktion zum Schreiben des Servernamens
    -- https://jdhao.github.io/2021/02/20/inverse_search_setup_neovim_vimtex/
    -- der eigentliche code der Homepage hatte nicht funktioniert, aber dieser hier
    -- local function write_server_name()
    --   local nvim_server_file = (vim.fn.has("win32") == 1 and os.getenv("TEMP") or "/tmp") .. "/vimtexserver.txt"
    --   local servername = vim.v.servername
    --   local file = io.open(nvim_server_file, "w")
    --   file:write(servername)
    --   file:close()
    -- end

    -- Auto-Befehle für VimTeX
    local vimtex_group = vim.api.nvim_create_augroup("vimtex_common", { clear = true })
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "tex",
    --   callback = write_server_name,
    --   group = "vimtex_common",
    -- })

    -- Vimtex Konfiguration

    -- vim.g.tex_flavor = "latex"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_method = "sioyek"
    --
    -- SKIM
    -- vim.g.vimtex_view_method = "skim"
    --
    -- vim.g.vimtex_view_skim_sync = 1     -- Value 1 allows forward search after every successful compilation
    -- vim.g.vimtex_view_skim_activate = 1 --# Value 1 allows change focus to skim after command `:VimtexView` is given
    --
    -- -- Skim Konfiguration für Vimtex
    -- vim.g.vimtex_view_skim = {
    --   executable = 'open',
    --   args = { '-a', 'Skim' }
    -- }

    -- VimTeX-Kürzel nur im jeweiligen TeX-Buffer anlegen.
    vim.api.nvim_create_autocmd("FileType", {
      group = vimtex_group,
      pattern = "tex",
      callback = function(args)
        local function map(lhs, rhs)
          vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true })
        end

        map("<Localleader>lu", "<cmd>VimtexCompile<CR>")

        -- ============================================================================
        -- Finale PDF mit qpdf
        -- ============================================================================

        -- vim.keymap.set("n", "<Localleader>lf", function()
        --   vim.cmd("write")
        --
        --   local dir = vim.fn.expand("%:p:h")
        --   local basename = vim.fn.expand("%:t:r")
        --   local date = os.date("%Y-%m-%d")
        --
        --   local input_pdf = basename .. ".pdf"
        --   local output_pdf = basename .. "-" .. date .. ".pdf"
        --
        --   local cmd = string.format(
        --     "cd %s && " .. "qpdf " .. "--stream-data=compress " .. "--recompress-flate " .. "%s %s",
        --     vim.fn.shellescape(dir),
        --     vim.fn.shellescape(input_pdf),
        --     vim.fn.shellescape(output_pdf)
        --   )
        --
        --   vim.cmd("botright split | terminal " .. cmd)
        -- end, {
        --   desc = "PDF finalisieren mit qpdf",
        -- })
        --
        -- -- ============================================================================
        -- -- Kleine PDF mit Ghostscript
        -- -- ============================================================================
        --
        -- vim.keymap.set("n", "<Localleader>lp", function()
        --   vim.cmd("write")
        --
        --   local dir = vim.fn.expand("%:p:h")
        --   local basename = vim.fn.expand("%:t:r")
        --   local date = os.date("%Y-%m-%d")
        --
        --   local input_pdf = basename .. ".pdf"
        --   local output_pdf = basename .. "-" .. date .. "-small.pdf"
        --
        --   local cmd = string.format(
        --     "cd %s && "
        --       .. "gs "
        --       .. "-sDEVICE=pdfwrite "
        --       .. "-dCompatibilityLevel=1.7 "
        --       .. "-dNOPAUSE "
        --       .. "-dBATCH "
        --       .. "-dQUIET "
        --       .. "-sOutputFile=%s "
        --       .. "%s",
        --     vim.fn.shellescape(dir),
        --     vim.fn.shellescape(output_pdf),
        --     vim.fn.shellescape(input_pdf)
        --   )
        --
        --   vim.cmd("botright split | terminal " .. cmd)
        -- end, {
        --   desc = "PDF stark komprimieren mit Ghostscript",
        -- })
        -- ============================================================================
        -- Finale PDF mit qpdf
        -- ============================================================================

        vim.keymap.set("n", "<Localleader>lf", function()
          vim.cmd("write")

          local dir = vim.fn.expand("%:p:h")
          local basename = vim.fn.expand("%:t:r")
          local date = os.date("%Y-%m-%d")

          local input_pdf = basename .. ".pdf"
          local output_pdf = basename .. "-" .. date .. ".pdf"

          vim.notify("qpdf läuft …", vim.log.levels.INFO)

          vim.system({
            "qpdf",
            "--stream-data=compress",
            "--recompress-flate",
            input_pdf,
            output_pdf,
          }, {
            cwd = dir,
            text = true,
          }, function(result)
            vim.schedule(function()
              if result.code == 0 then
                vim.notify("PDF erstellt:\n" .. output_pdf, vim.log.levels.INFO)
              else
                vim.notify("qpdf fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
              end
            end)
          end)
        end, {
          buffer = args.buf,
          desc = "PDF finalisieren mit qpdf",
        })

        -- ============================================================================
        -- Kleine PDF mit Ghostscript
        -- ============================================================================

        vim.keymap.set("n", "<Localleader>lp", function()
          vim.cmd("write")

          local dir = vim.fn.expand("%:p:h")
          local basename = vim.fn.expand("%:t:r")
          local date = os.date("%Y-%m-%d")

          local input_pdf = basename .. ".pdf"
          local output_pdf = basename .. "-" .. date .. "-small.pdf"

          vim.notify("Ghostscript läuft …", vim.log.levels.INFO)

          vim.system({
            "gs",
            "-sDEVICE=pdfwrite",
            "-dCompatibilityLevel=1.7",
            "-dNOPAUSE",
            "-dBATCH",
            "-dQUIET",
            "-sOutputFile=" .. output_pdf,
            input_pdf,
          }, {
            cwd = dir,
            text = true,
          }, function(result)
            vim.schedule(function()
              if result.code == 0 then
                vim.notify("PDF erstellt:\n" .. output_pdf, vim.log.levels.INFO)
              else
                vim.notify("Ghostscript fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
              end
            end)
          end)
        end, {
          buffer = args.buf,
          desc = "PDF stark komprimieren mit Ghostscript",
        })

        map("<Localleader>vc", "<cmd>VimtexClean<CR>")
        map("<Localleader>vC", "<cmd>VimtexClean!<CR>")
        map("<Localleader>ve", "<cmd>VimtexErrors<CR>")
        map("<Localleader>vl", "<cmd>VimtexView<CR>")
        map("<Localleader>vq", "<cmd>VimtexLog<CR>")
        map("<Localleader>vt", "<cmd>VimtexTocToggle<CR>")
      end,
    })

    -- Mapping für :VimtexClean auf <leader>cc
    -- vim.api.nvim_set_keymap("n", "<leader>vc", ":VimtexClean<CR>", { noremap = true, silent = true })
    --
    --
    -- latexmk configuration to remove auxiliary files except for .log
    -- vim.g.vimtex_compiler_latexmk = {
    --   build_dir = "",
    --   callback = 1,
    --   continuous = 1,
    --   executable = "latexmk",
    --   -- options = {
    --   --   "-pdfxe", -- <- wichtig: PDF-Modus mit xelatex
    --   --   "-shell-escape",
    --   --   "-verbose",
    --   --   "-file-line-error",
    --   --   "-interaction=nonstopmode",
    --   --   "-synctex=1",
    --   -- },
    --   options = {
    --     -- "-pdf",
    --     "-xelatex", -- damit ich mit Iosevka kompilieren kann
    --     "-shell-escape",
    --     "-verbose",
    --     "-file-line-error",
    --     "-interaction=nonstopmode",
    --     "-synctex=1",
    --   },
    --   -- Hier den `aux_dir` einfügen, um die Hilfsdateien in einem speziellen Verzeichnis abzulegen
    --   aux_dir = "auxiliary_files",
    -- }
    vim.g.vimtex_compiler_method = "latexmk"

    vim.g.vimtex_compiler_latexmk_engines = {
      _ = "-xelatex",
      xelatex = "-xelatex",
      pdflatex = "-pdf",
      lualatex = "-lualatex",
    }

    vim.g.vimtex_compiler_latexmk = {
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      options = {
        "-shell-escape",
        -- "-verbose", -- gibt zusätzliche Informationen beim kompilieren, z.B. welche Programme gestartete werden, nicht zwingend notwendig
        "-file-line-error",
        "-interaction=nonstopmode",
        "-synctex=1",
      },
      -- aux_dir = "auxiliary_files", -- ist in der latexmkrc definiert
    } -- Zusätzliche Konfigurationen damit vimtex immer das Verzeichnis der tex datei als arbeitsverzeichnis benutzt
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_quickfix_open_on_warning = 0

    -- Mapping für die Bereinigung der Hilfsdateien im richtigen Verzeichnis
    -- vim.api.nvim_set_keymap('n', '<Localleader>c', ':lua CleanLatexFiles()<CR>', { noremap = true, silent = true })
  end,
}

-- https://gist.github.com/kha-dinh/c8540052854f3c6954b047abd506b799
-- Versuch Sioyek mit nvim remote für inverse search
-- funktioniert nicht

-- anderer Versuch aus git https://github.com/lervag/vimtex/issues/2323#issuecomment-1047021336
-- funktioniert nicht
