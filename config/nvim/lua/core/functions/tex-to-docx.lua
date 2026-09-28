local M = {}

local word_templates = require("core.functions.word-templates")

function M.tex_to_docx()
  local tex = vim.api.nvim_buf_get_name(0)

  if tex == "" or vim.bo.filetype ~= "tex" then
    vim.notify("Keine LaTeX-Datei geöffnet", vim.log.levels.ERROR)
    return
  end

  local dir = vim.fs.dirname(tex)
  local stem = vim.fn.fnamemodify(tex, ":t:r")
  local output = dir .. "/" .. stem .. ".docx"

  local bib = vim.fn.expand("~/Library/texmf/bibtex/bib/Zotero.bib")

  if vim.fn.filereadable(bib) == 0 then
    vim.notify("Bib-Datei nicht gefunden: " .. bib, vim.log.levels.ERROR)
    return
  end

  word_templates.select(function(selected)
    local args = {
      "pandoc",
      tex,
      "--from=latex",
      "--to=docx",
      "--citeproc",
      "--bibliography=" .. bib,
      "--reference-doc=" .. selected.path,
      "--resource-path=" .. dir,
      "-o",
      output,
    }

    vim.system(args, {
      cwd = dir,
      text = true,
    }, function(result)
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

vim.keymap.set("n", "<localleader>ld", M.tex_to_docx, {
  desc = "LaTeX → DOCX",
})
vim.keymap.set("n", "<localleader>vd", M.tex_to_docx, {
  desc = "LaTeX → DOCX",
})

return M
