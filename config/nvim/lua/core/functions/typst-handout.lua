local M = {}

function M.build()
  local source = vim.api.nvim_buf_get_name(0)

  if vim.bo.filetype ~= "typst" or not source:match("%.typ$") then
    vim.notify("Bitte eine benannte .typ-Datei öffnen", vim.log.levels.WARN)
    return
  end

  for _, executable in ipairs({ "typst", "qpdf" }) do
    if vim.fn.executable(executable) ~= 1 then
      vim.notify(executable .. " wurde nicht gefunden", vim.log.levels.ERROR)
      return
    end
  end

  -- Datei vor dem Kompilieren speichern
  local ok, err = pcall(vim.cmd, "silent update")
  if not ok then
    vim.notify("Typst-Datei konnte nicht gespeichert werden: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local dir = vim.fs.dirname(source)
  local stem = vim.fn.fnamemodify(source, ":t:r")

  local name = stem .. "-" .. os.date("%Y-%m-%d") .. "-handout"

  local output = vim.fs.joinpath(dir, name .. ".pdf")
  local compressed_output = vim.fs.joinpath(dir, name .. ".tmp.pdf")

  vim.notify("Kompiliere Typst-Handout: " .. name .. ".pdf")

  -- Handout direkt über sys.inputs aktivieren
  vim.system({
    "typst",
    "compile",
    "--root",
    "/",
    "--input",
    "handout=true",
    source,
    output,
  }, { cwd = dir, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Handout-Kompilierung fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      -- PDF komprimieren
      vim.system({
        "qpdf",
        "--stream-data=compress",
        "--recompress-flate",
        output,
        compressed_output,
      }, { cwd = dir, text = true }, function(compressed)
        vim.schedule(function()
          if compressed.code ~= 0 then
            vim.fn.delete(compressed_output)

            vim.notify("Handout erstellt; qpdf-Kompression fehlgeschlagen: " .. output, vim.log.levels.WARN)
            return
          end

          local renamed, rename_error = os.rename(compressed_output, output)

          if not renamed then
            vim.notify(
              "Komprimiertes Handout konnte nicht übernommen werden: " .. tostring(rename_error),
              vim.log.levels.ERROR
            )
            return
          end

          vim.notify("Typst-Handout erstellt: " .. output)

          -- Handout in Sioyek öffnen
          if vim.fn.executable("sioyek") == 1 then
            vim.fn.jobstart({ "sioyek", output }, { detach = true })
          end
        end)
      end)
    end)
  end)
end

-- Neovim-Befehl
vim.api.nvim_create_user_command("TypstHandout", M.build, { desc = "Touying-Handout bauen" })

-- Tastenkombination
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>lh", M.build, {
      buffer = args.buf,
      silent = true,
      desc = "Typst-Handout bauen",
    })
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>bh", M.build, {
      buffer = args.buf,
      silent = true,
      desc = "Typst-Handout bauen",
    })
  end,
})

return M
