local M = {}
local running = {}

function M.compile(compressor)
  local buf = vim.api.nvim_get_current_buf()
  local source = vim.api.nvim_buf_get_name(buf)

  if source == "" or vim.bo[buf].filetype ~= "typst" then
    vim.notify("Keine Typst-Datei geöffnet", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable("typst") == 0 then
    vim.notify("Typst ist nicht im PATH", vim.log.levels.ERROR)
    return
  end
  if compressor and vim.fn.executable(compressor) == 0 then
    vim.notify(compressor .. " ist nicht im PATH", vim.log.levels.ERROR)
    return
  end
  if running[source] then
    vim.notify("Typst-PDF wird bereits erstellt", vim.log.levels.WARN)
    return
  end

  local saved, err = pcall(vim.cmd, "silent update")
  if not saved then
    vim.notify("Typst-Datei konnte nicht gespeichert werden: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local output = vim.fn.fnamemodify(source, ":r") .. ".pdf"
  local dated_output
  local command
  if compressor then
    dated_output = vim.fn.fnamemodify(source, ":r") .. "-" .. os.date("%Y-%m-%d")
      .. (compressor == "gs" and "-small.pdf" or ".pdf")
    command = compressor == "gs" and {
      "gs",
      "-sDEVICE=pdfwrite",
      "-dCompatibilityLevel=1.7",
      "-dNOPAUSE",
      "-dBATCH",
      "-dQUIET",
      "-sOutputFile=" .. dated_output,
      output,
    } or {
      "qpdf",
      "--stream-data=compress",
      "--recompress-flate",
      output,
      dated_output,
    }
  end

  running[source] = true
  -- Root / erlaubt die absoluten Imports in der KN-Touying-Vorlage.
  vim.system({ "typst", "compile", "--root", "/", source, output }, {
    cwd = vim.fs.dirname(source),
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        if command then
          vim.notify("Typst-PDF kompiliert; " .. compressor .. " läuft …", vim.log.levels.INFO)
          vim.system(command, { cwd = vim.fs.dirname(source), text = true }, function(compressed)
            vim.schedule(function()
              running[source] = nil
              if compressed.code == 0 then
                vim.notify("Typst-PDF erstellt: " .. dated_output)
              else
                local details = (compressed.stderr or ""):gsub("%s+$", "")
                if details == "" then
                  details = (compressed.stdout or ""):gsub("%s+$", "")
                end
                vim.notify(compressor .. " fehlgeschlagen; unkomprimierte PDF liegt unter:\n"
                  .. output .. "\n" .. details, vim.log.levels.ERROR)
              end
            end)
          end)
        else
          running[source] = nil
          vim.notify("Typst-PDF erstellt: " .. output)
        end
      else
        running[source] = nil
        local details = (result.stderr or ""):gsub("%s+$", "")
        if details == "" then
          details = (result.stdout or ""):gsub("%s+$", "")
        end
        vim.notify("Typst-Kompilierung fehlgeschlagen:\n" .. details, vim.log.levels.ERROR)
      end
    end)
  end)
end

local group = vim.api.nvim_create_augroup("TypstCompileMapping", { clear = true })
local function set_map(buf)
  vim.keymap.set("n", "<localleader>lw", M.compile, {
    buffer = buf,
    silent = true,
    desc = "Typst: PDF ohne Kompression kompilieren",
  })
  vim.keymap.set("n", "<localleader>lf", function() M.compile("qpdf") end, {
    buffer = buf,
    silent = true,
    desc = "Typst: PDF kompilieren und mit qpdf finalisieren",
  })
  vim.keymap.set("n", "<localleader>lp", function() M.compile("gs") end, {
    buffer = buf,
    silent = true,
    desc = "Typst: PDF kompilieren und mit Ghostscript komprimieren",
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "typst",
  callback = function(args)
    set_map(args.buf)
  end,
})

if vim.bo.filetype == "typst" then
  set_map(vim.api.nvim_get_current_buf())
end

return M
