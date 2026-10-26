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
  local ok, err = pcall(vim.cmd, "silent update")
  if not ok then
    vim.notify("Typst-Datei konnte nicht gespeichert werden: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local show_line
  for i, line in ipairs(lines) do
    if line:match("^%s*#show:%s*kn%-vorlage%.with%s*%(") then
      show_line = i
      break
    end
  end
  if not show_line then
    vim.notify("Keine #show: kn-vorlage.with(...) in dieser Typst-Datei gefunden", vim.log.levels.WARN)
    return
  end

  local copy = vim.deepcopy(lines)
  local has_handout = false
  for i = show_line + 1, #copy do
    if copy[i]:match("^%s*%)") then
      break
    end
    if copy[i]:match("^%s*handout%s*:") then
      copy[i] = copy[i]:gsub("handout%s*:%s*[%a]+", "handout: true", 1)
      has_handout = true
      break
    end
  end
  if not has_handout then
    table.insert(copy, show_line + 1, "  handout: true,")
  end
  local dir = vim.fs.dirname(source)
  local stem = vim.fn.fnamemodify(source, ":t:r")
  local name = stem .. "-" .. os.date("%Y-%m-%d") .. "-handout"
  local temporary = vim.fs.joinpath(dir, "." .. name .. "-" .. vim.fn.getpid() .. ".tmp.typ")
  local output = vim.fs.joinpath(dir, name .. ".pdf")
  local compressed_output = vim.fs.joinpath(dir, name .. ".tmp.pdf")
  local written, result = pcall(vim.fn.writefile, copy, temporary)
  if not written or result ~= 0 then
    vim.notify("Temporäre Handout-Datei konnte nicht erstellt werden", vim.log.levels.ERROR)
    return
  end
  vim.notify("Kompiliere Typst-Handout: " .. name .. ".pdf")
  vim.system({ "typst", "compile", "--root", "/", temporary, output }, { cwd = dir, text = true }, function(result)
    vim.schedule(function()
      vim.fn.delete(temporary)
      if result.code ~= 0 then
        vim.notify("Handout-Kompilierung fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end
      vim.system(
        { "qpdf", "--stream-data=compress", "--recompress-flate", output, compressed_output },
        { cwd = dir, text = true },
        function(compressed)
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
            if vim.fn.executable("sioyek") == 1 then
              vim.fn.jobstart({ "sioyek", output }, { detach = true })
            end
          end)
        end
      )
    end)
  end)
end

vim.api.nvim_create_user_command("TypstHandout", M.build, { desc = "Touying-Handout bauen" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>bh", M.build, { buffer = args.buf, silent = true, desc = "Typst-Handout bauen" })
  end,
})
vim.api.nvim_create_user_command("TypstHandout", M.build, { desc = "Touying-Handout bauen" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>lh", M.build, { buffer = args.buf, silent = true, desc = "Typst-Handout bauen" })
  end,
})

return M
