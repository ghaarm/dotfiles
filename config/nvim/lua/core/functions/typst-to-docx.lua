local M = {}
local word_templates = require("core.functions.word-templates")

function M.typst_to_docx()
  local source = vim.api.nvim_buf_get_name(0)
  if source == "" or vim.bo.filetype ~= "typst" then
    vim.notify("Keine Typst-Datei geöffnet", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable("pandoc") ~= 1 then
    vim.notify("Pandoc ist nicht im PATH", vim.log.levels.ERROR)
    return
  end

  local saved, err = pcall(vim.cmd, "silent update")
  if not saved then
    vim.notify("Typst-Datei konnte nicht gespeichert werden: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local dir = vim.fs.dirname(source)
  local output = vim.fn.fnamemodify(source, ":r") .. ".docx"
  local bib = vim.fn.expand("~/Library/texmf/bibtex/bib/Zotero.bib")
  if vim.fn.filereadable(bib) ~= 1 then
    vim.notify("Bib-Datei nicht gefunden: " .. bib, vim.log.levels.ERROR)
    return
  end

  word_templates.select(function(selected)
    vim.system({
      "pandoc", source, "--from=typst", "--to=docx", "--citeproc",
      "--bibliography=" .. bib, "--reference-doc=" .. selected.path,
      "--resource-path=" .. dir, "-o", output,
    }, { cwd = dir, text = true }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify("DOCX erstellt: " .. output)
        else
          vim.notify("Pandoc-Fehler:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        end
      end)
    end)
  end)
end

vim.api.nvim_create_user_command("TypstToDocx", M.typst_to_docx, { desc = "Typst nach DOCX exportieren" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    for _, lhs in ipairs({ "<localleader>ld", "<localleader>vd" }) do
      vim.keymap.set("n", lhs, M.typst_to_docx, {
        buffer = args.buf, silent = true, desc = "Typst → DOCX",
      })
    end
  end,
})

return M
