require("core.functions.latex-comment-figures")

local running = {}

local function stop_vimtex()
  local function is_running()
    return vim.fn.eval("exists('b:vimtex.compiler') && b:vimtex.compiler.is_running()") == 1
  end

  if is_running() then
    vim.cmd("VimtexStop")
    -- jobstop arbeitet asynchron; erst nach dem Ende die Quelldatei verändern.
    if not vim.wait(2000, function()
      return not is_running()
    end, 20) then
      error("VimTeX-Compiler wurde nicht rechtzeitig beendet")
    end
  end
end

local function write_without_texlab_build()
  local uri = vim.uri_from_bufnr(0)
  local notifications = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "texlab" })) do
    local rpc = client.rpc
    local notify = rpc.notify
    notifications[#notifications + 1] = { rpc = rpc, notify = notify }
    -- Nur die Speichermeldung dieser Datei unterdrücken. didChange, andere
    -- Dateien und andere LSP-Server bleiben unverändert.
    rpc.notify = function(method, params)
      if method == "textDocument/didSave" and params.textDocument.uri == uri then
        return true
      end
      return notify(method, params)
    end
  end

  local ok, err = pcall(vim.cmd, "write")
  -- Auch nach einem Schreibfehler das normale Speicherverhalten wiederherstellen.
  for _, entry in ipairs(notifications) do
    entry.rpc.notify = entry.notify
  end
  if not ok then
    error(err)
  end
end

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

local function build_public_pdf(compressor)
  local compressor_name = compressor == "gs" and "Ghostscript" or "qpdf"
  local texfile = vim.api.nvim_buf_get_name(0)
  if not texfile:match("%.tex$") then
    vim.notify("Bitte eine benannte .tex-Datei öffnen", vim.log.levels.WARN)
    return
  end

  if running[texfile] then
    vim.notify("Public-PDF wird für diese Datei bereits erstellt", vim.log.levels.WARN)
    return
  end

  for _, executable in ipairs({ "latexmk", compressor }) do
    if vim.fn.executable(executable) ~= 1 then
      vim.notify(executable .. " wurde nicht gefunden", vim.log.levels.ERROR)
      return
    end
  end

  -- Die vorhandene Kommentierfunktion beachtet auch den Hinweis „nicht kommentieren“.
  local ok, err = pcall(function()
    stop_vimtex()
    vim.cmd("LatexCommentFloats")
    write_without_texlab_build()
  end)
  if not ok then
    vim.notify("TeX-Datei konnte nicht vorbereitet werden:\n" .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.fnamemodify(texfile, ":h")
  local basename = vim.fn.fnamemodify(texfile, ":t:r")
  local public_name = basename .. "-" .. os.date("%Y-%m-%d") .. "-public"
  local public_pdf = dir .. "/" .. public_name .. ".pdf"
  local public_synctex = dir .. "/" .. public_name .. ".synctex.gz"
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

  local compile_command = {
    "latexmk",
    "-xelatex",
    "-interaction=nonstopmode",
    "-file-line-error",
    "-synctex=1",
    "-outdir=.",
    "-emulate-aux-dir",
    "-jobname=" .. public_name,
    vim.fn.fnamemodify(texfile, ":t"),
  }
  -- Eine fehlende SyncTeX-Datei löst bei latexmk allein keinen neuen TeX-Lauf aus.
  if vim.fn.filereadable(public_synctex) ~= 1 then
    table.insert(compile_command, 2, "-g")
  end

  run(compile_command, function(result)
    if result.code ~= 0 or vim.fn.filereadable(public_pdf) ~= 1 then
      running[texfile] = nil
      show_build_error("Public-Kompilierung fehlgeschlagen", (result.stdout or "") .. (result.stderr or ""))
      return
    end

    local compression_command = compressor == "gs" and {
      "gs",
      "-sDEVICE=pdfwrite",
      "-dCompatibilityLevel=1.7",
      "-dNOPAUSE",
      "-dBATCH",
      "-dQUIET",
      "-sOutputFile=" .. temporary_pdf,
      public_pdf,
    } or {
      "qpdf",
      "--stream-data=compress",
      "--recompress-flate",
      public_pdf,
      temporary_pdf,
    }
    vim.notify("Public-PDF kompiliert – komprimiere mit " .. compressor_name .. " ...")
    run(compression_command, function(compression)
      running[texfile] = nil
      if compression.code ~= 0 then
        vim.fn.delete(temporary_pdf)
        show_build_error(
          compressor_name .. "-Kompression fehlgeschlagen; unkomprimierte Public-PDF bleibt erhalten",
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
      if vim.fn.filereadable(public_synctex) ~= 1 then
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

vim.api.nvim_create_user_command("LatexCommentCompile", function()
  build_public_pdf("qpdf")
end, {
  force = true,
  desc = "LaTeX floats comment out and build public PDF",
})

vim.keymap.set("n", "<localleader>lx", function()
  build_public_pdf("qpdf")
end, {
  silent = true,
  desc = "Build public PDF without commented figures and tables",
})

vim.keymap.set("n", "<localleader>lz", function()
  build_public_pdf("gs")
end, {
  silent = true,
  desc = "Build public PDF without commented figures and tables using Ghostscript",
})
