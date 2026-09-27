require("core.functions.latex-comment-figures")

local running = {}

local function show_build_error(message, output)
  vim.notify(message, vim.log.levels.ERROR)
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(message .. "\n\n" .. output, "\n", { plain = true }))
  vim.bo[buf].modifiable = false
end

local function build_public_pdf()
  local texfile = vim.api.nvim_buf_get_name(0)
  if not texfile:match("%.tex$") then
    vim.notify("Bitte eine benannte .tex-Datei öffnen", vim.log.levels.WARN)
    return
  end

  if running[texfile] then
    vim.notify("Public-PDF wird für diese Datei bereits erstellt", vim.log.levels.WARN)
    return
  end

  for _, executable in ipairs({ "latexmk", "qpdf" }) do
    if vim.fn.executable(executable) ~= 1 then
      vim.notify(executable .. " wurde nicht gefunden", vim.log.levels.ERROR)
      return
    end
  end

  -- Die vorhandene Kommentierfunktion beachtet auch den Hinweis „nicht kommentieren“.
  local ok, err = pcall(function()
    vim.cmd("LatexCommentFloats")
    vim.cmd("write")
  end)
  if not ok then
    vim.notify("TeX-Datei konnte nicht vorbereitet werden:\n" .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.fnamemodify(texfile, ":h")
  local basename = vim.fn.fnamemodify(texfile, ":t:r")
  local public_name = basename .. "-" .. os.date("%Y-%m-%d") .. "-public"
  local public_pdf = dir .. "/" .. public_name .. ".pdf"
  local temporary_pdf = dir .. "/" .. public_name .. ".tmp.pdf"
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local inverse_search = '"' .. vim.v.progpath .. '" --headless -c "VimtexInverseSearch %2 \'%1\'"'

  running[texfile] = true

  local function run(cmd, on_exit)
    local started, start_error = pcall(vim.system, cmd, { cwd = dir, text = true }, function(result)
      vim.schedule(function()
        on_exit(result)
      end)
    end)
    if not started then
      running[texfile] = nil
      vim.notify(cmd[1] .. " konnte nicht gestartet werden:\n" .. tostring(start_error), vim.log.levels.ERROR)
    end
  end

  vim.notify("Kompiliere Public-PDF: " .. public_name .. ".pdf")

  run({
    "latexmk",
    "-xelatex",
    "-interaction=nonstopmode",
    "-file-line-error",
    "-synctex=1",
    "-outdir=.",
    "-emulate-aux-dir",
    "-jobname=" .. public_name,
    vim.fn.fnamemodify(texfile, ":t"),
  }, function(result)
    if result.code ~= 0 or vim.fn.filereadable(public_pdf) ~= 1 then
      running[texfile] = nil
      show_build_error("Public-Kompilierung fehlgeschlagen", (result.stdout or "") .. (result.stderr or ""))
      return
    end

    vim.notify("Public-PDF kompiliert – komprimiere mit qpdf ...")
    run({
      "qpdf",
      "--stream-data=compress",
      "--recompress-flate",
      public_pdf,
      temporary_pdf,
    }, function(compression)
      running[texfile] = nil
      if compression.code ~= 0 then
        vim.fn.delete(temporary_pdf)
        show_build_error(
          "qpdf-Kompression fehlgeschlagen; unkomprimierte Public-PDF bleibt erhalten",
          (compression.stdout or "") .. (compression.stderr or "")
        )
        return
      end

      local renamed, rename_error = os.rename(temporary_pdf, public_pdf)
      if not renamed then
        vim.notify(
          "Komprimierte PDF konnte nicht übernommen werden:\n" .. tostring(rename_error),
          vim.log.levels.ERROR
        )
        return
      end

      vim.notify("Public-PDF erstellt und komprimiert:\n" .. public_pdf)
      if vim.fn.filereadable(dir .. "/" .. public_name .. ".synctex.gz") ~= 1 then
        vim.notify("Keine SyncTeX-Datei für die Public-PDF gefunden", vim.log.levels.WARN)
      end

      if vim.fn.executable("sioyek") ~= 1 then
        vim.notify("Sioyek wurde nicht gefunden; PDF liegt unter:\n" .. public_pdf, vim.log.levels.WARN)
        return
      end

      local opened, job = pcall(vim.fn.jobstart, {
        "sioyek",
        "--inverse-search",
        inverse_search,
        "--forward-search-file",
        texfile,
        "--forward-search-line",
        tostring(current_line),
        public_pdf,
      }, { detach = true })
      if not opened or job <= 0 then
        vim.notify("Sioyek konnte nicht geöffnet werden; PDF liegt unter:\n" .. public_pdf, vim.log.levels.WARN)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("LatexCommentCompile", build_public_pdf, {
  force = true,
  desc = "LaTeX floats comment out and build public PDF",
})

vim.keymap.set("n", "<localleader>lx", build_public_pdf, {
  silent = true,
  desc = "Build public PDF without commented figures and tables",
})
