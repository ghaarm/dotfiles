local floats = require("core.functions.typst-comment-figures")
local running = {}

local function build(compressor)
  local source = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype ~= "typst" or not source:match("%.typ$") then
    vim.notify("Bitte eine benannte .typ-Datei öffnen", vim.log.levels.WARN)
    return
  end
  if running[source] then
    vim.notify("Public-PDF wird bereits erstellt", vim.log.levels.WARN)
    return
  end
  for _, executable in ipairs({ "typst", compressor }) do
    if vim.fn.executable(executable) ~= 1 then
      vim.notify(executable .. " wurde nicht gefunden", vim.log.levels.ERROR)
      return
    end
  end

  floats.comment()
  local ok, err = pcall(vim.cmd, "write")
  if not ok then
    vim.notify("Typst-Datei konnte nicht gespeichert werden:\n" .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local dir = vim.fs.dirname(source)
  local name = vim.fn.fnamemodify(source, ":t:r") .. "-" .. os.date("%Y-%m-%d") .. "-public"
  local pdf = vim.fs.joinpath(dir, name .. ".pdf")
  local temporary = vim.fs.joinpath(dir, name .. ".tmp.pdf")
  local line = vim.api.nvim_win_get_cursor(0)[1]
  running[source] = true
  vim.notify("Kompiliere Public-PDF: " .. name .. ".pdf")

  vim.system({ "typst", "compile", "--root", "/", source, pdf }, { cwd = dir, text = true }, function(compiled)
    vim.schedule(function()
      if compiled.code ~= 0 then
        running[source] = nil
        vim.notify("Typst-Kompilierung fehlgeschlagen:\n" .. (compiled.stderr or ""), vim.log.levels.ERROR)
        return
      end
      local cmd = compressor == "gs" and {
        "gs", "-sDEVICE=pdfwrite", "-dCompatibilityLevel=1.7", "-dNOPAUSE", "-dBATCH", "-dQUIET",
        "-sOutputFile=" .. temporary, pdf,
      } or { "qpdf", "--stream-data=compress", "--recompress-flate", pdf, temporary }
      vim.system(cmd, { cwd = dir, text = true }, function(compressed)
        vim.schedule(function()
          running[source] = nil
          if compressed.code ~= 0 then
            vim.fn.delete(temporary)
            vim.notify("PDF-Kompression fehlgeschlagen; Public-PDF liegt unter:\n" .. pdf, vim.log.levels.ERROR)
            return
          end
          local renamed, rename_error = os.rename(temporary, pdf)
          if not renamed then
            vim.notify("Komprimierte PDF konnte nicht übernommen werden:\n" .. tostring(rename_error), vim.log.levels.ERROR)
            return
          end
          vim.notify("Public-PDF erstellt: " .. pdf)
          if vim.fn.executable("sioyek") == 1 then
            vim.fn.jobstart({ "sioyek", "--forward-search-file", source,
              "--forward-search-line", tostring(line), pdf }, { detach = true })
          end
        end)
      end)
    end)
  end)
end

vim.api.nvim_create_user_command("TypstCommentCompile", function() build("qpdf") end,
  { desc = "Typst-Abbildungen auskommentieren und Public-PDF bauen" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>lx", function() build("qpdf") end,
      { buffer = args.buf, silent = true, desc = "Typst-Public-PDF mit qpdf" })
    vim.keymap.set("n", "<localleader>lz", function() build("gs") end,
      { buffer = args.buf, silent = true, desc = "Typst-Public-PDF mit Ghostscript" })
  end,
})

return { build = build }
