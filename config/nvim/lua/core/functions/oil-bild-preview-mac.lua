-- -- Bild in der Vorschau öffnen und automatisch die Werkzeugleiste öffnen

local image_extensions = {
  png = true,
  jpg = true,
  jpeg = true,
}

local M = {}

local function has_image_extension(path)
  local extension = path:match("%.([^./]+)$")
  extension = extension and extension:lower()
  return extension and image_extensions[extension] == true
end

local function image_path_variants(path)
  if has_image_extension(path) then
    return { path }
  end

  return {
    path .. ".png",
    path .. ".jpg",
    path .. ".jpeg",
  }
end

local function find_balanced_content(text, start_pos, opening, closing)
  if text:sub(start_pos, start_pos) ~= opening then
    return nil
  end

  local depth = 0

  for index = start_pos, #text do
    local char = text:sub(index, index)

    if char == opening then
      depth = depth + 1
    elseif char == closing then
      depth = depth - 1

      if depth == 0 then
        return text:sub(start_pos + 1, index - 1), start_pos, index
      end
    end
  end
end

local function skip_whitespace(text, start_pos)
  local _, end_pos = text:find("^%s*", start_pos)
  return end_pos + 1
end

local function includegraphics_argument_at(line, command_start)
  local pos = command_start + #"\\includegraphics"
  pos = skip_whitespace(line, pos)

  if line:sub(pos, pos) == "[" then
    local _, _, option_end = find_balanced_content(line, pos, "[", "]")

    if option_end then
      pos = skip_whitespace(line, option_end + 1)
    end
  end

  if line:sub(pos, pos) ~= "{" then
    return nil
  end

  return find_balanced_content(line, pos, "{", "}")
end

local function get_path_from_line()
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  if vim.bo.filetype == "typst" then
    local path = line:match('#?image%s*%(%s*"([^"]+)"')
    if path then
      return path
    end
  end
  local first_includegraphics_path

  local search_from = 1

  while true do
    local command_start = line:find("\\includegraphics", search_from, true)

    if not command_start then
      break
    end

    local path, start_col, end_col = includegraphics_argument_at(line, command_start)

    if path then
      first_includegraphics_path = first_includegraphics_path or path

      if start_col <= cursor_col and cursor_col <= end_col then
        return path
      end
    end

    search_from = command_start + 1
  end

  if first_includegraphics_path then
    return first_includegraphics_path
  end

  for start_col, path, end_col in line:gmatch("(){([^}]+)}()") do
    if has_image_extension(path) then
      if start_col <= cursor_col and cursor_col < end_col then
        return path
      end

      return path
    end
  end
end

local function get_vimtex_root()
  local vimtex = vim.b.vimtex

  if type(vimtex) == "table" and vimtex.root then
    return vim.fn.fnamemodify(vimtex.root, ":p")
  end

  local ok, root = pcall(vim.fn["vimtex#paths#get_root"])
  if ok and type(root) == "string" and root ~= "" then
    return vim.fn.fnamemodify(root, ":p")
  end
end

local function get_vimtex_main()
  local vimtex = vim.b.vimtex

  if type(vimtex) == "table" and vimtex.tex then
    return vim.fn.fnamemodify(vimtex.tex, ":p")
  end

  local ok, main = pcall(vim.fn["vimtex#paths#get_main"])
  if ok and type(main) == "string" and main ~= "" then
    return vim.fn.fnamemodify(main, ":p")
  end
end

local function dedupe_paths(paths)
  local seen = {}
  local deduped = {}

  for _, path in ipairs(paths) do
    if path and path ~= "" then
      local normalized = vim.fs.normalize(path)

      if not seen[normalized] then
        seen[normalized] = true
        table.insert(deduped, normalized)
      end
    end
  end

  return deduped
end

local function project_directories()
  local root = get_vimtex_root()
  local main_path = get_vimtex_main()
  local main_directory = main_path and vim.fn.fnamemodify(main_path, ":p:h")
  local buffer_directory = vim.fn.expand("%:p:h")

  return dedupe_paths({
    root,
    main_directory,
    buffer_directory,
    vim.fn.getcwd(),
  })
end

local function read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)

  if not ok then
    return nil
  end

  return table.concat(lines, "\n")
end

local function find_balanced_brace_content(text, from)
  local start_pos = text:find("{", from, true)

  if not start_pos then
    return nil
  end

  local depth = 0

  for index = start_pos, #text do
    local char = text:sub(index, index)

    if char == "{" then
      depth = depth + 1
    elseif char == "}" then
      depth = depth - 1

      if depth == 0 then
        return text:sub(start_pos + 1, index - 1)
      end
    end
  end
end

local function tex_path_variants(path)
  if path:match("%.tex$") then
    return { path }
  end

  return { path .. ".tex", path }
end

local function resolve_tex_input_path(input_path, current_file_directory)
  if vim.fn.fnamemodify(input_path, ":p") == input_path then
    for _, variant in ipairs(tex_path_variants(input_path)) do
      local normalized = vim.fs.normalize(variant)

      if vim.fn.filereadable(normalized) == 1 then
        return normalized
      end
    end
  end

  local base_directories = dedupe_paths(vim.list_extend({ current_file_directory }, project_directories()))

  for _, base_directory in ipairs(base_directories) do
    for _, variant in ipairs(tex_path_variants(input_path)) do
      local candidate = vim.fs.normalize(vim.fs.joinpath(base_directory, variant))

      if vim.fn.filereadable(candidate) == 1 then
        return candidate
      end
    end
  end
end

local function collect_input_files(tex_file, collected, seen)
  tex_file = vim.fs.normalize(tex_file)

  if seen[tex_file] or vim.fn.filereadable(tex_file) ~= 1 then
    return
  end

  seen[tex_file] = true
  table.insert(collected, tex_file)

  local content = read_file(tex_file)
  if not content then
    return
  end

  local tex_file_directory = vim.fn.fnamemodify(tex_file, ":p:h")

  for command_start, command in content:gmatch("()\\(input)%s*{") do
    local input_path = find_balanced_brace_content(content, command_start)
    local resolved = input_path and resolve_tex_input_path(input_path, tex_file_directory)

    if resolved then
      collect_input_files(resolved, collected, seen)
    end
  end

  for command_start, command in content:gmatch("()\\(include)%s*{") do
    local input_path = find_balanced_brace_content(content, command_start)
    local resolved = input_path and resolve_tex_input_path(input_path, tex_file_directory)

    if resolved then
      collect_input_files(resolved, collected, seen)
    end
  end
end

local function tex_files_for_graphicspath()
  local files = {}
  local seen = {}
  local root = get_vimtex_root()

  for _, tex_file in ipairs({ get_vimtex_main(), vim.fn.expand("%:p") }) do
    if tex_file and tex_file ~= "" then
      collect_input_files(tex_file, files, seen)
    end
  end

  if root and root ~= "" then
    for _, tex_file in ipairs(vim.fn.globpath(root, "**/*.tex", false, true)) do
      collect_input_files(tex_file, files, seen)
    end
  end

  return dedupe_paths(files)
end

local function get_graphicspath_directories()
  if vim.bo.filetype ~= "tex" and vim.bo.filetype ~= "plaintex" then
    return {}
  end

  local directories = {}

  for _, tex_file in ipairs(tex_files_for_graphicspath()) do
    if vim.fn.filereadable(tex_file) == 1 then
      local content = read_file(tex_file)

      if content then
        local search_from = 1

        while true do
          local graphicspath_start = content:find("\\graphicspath", search_from, true)

          if not graphicspath_start then
            break
          end

          local graphicspath_content = find_balanced_brace_content(content, graphicspath_start)

          if graphicspath_content then
            local tex_file_directory = vim.fn.fnamemodify(tex_file, ":p:h")

            for graphics_directory in graphicspath_content:gmatch("{([^{}]+)}") do
              table.insert(directories, vim.fs.joinpath(tex_file_directory, graphics_directory))

              for _, project_directory in ipairs(project_directories()) do
                table.insert(directories, vim.fs.joinpath(project_directory, graphics_directory))
              end
            end
          end

          search_from = graphicspath_start + 1
        end
      end
    end
  end

  return dedupe_paths(directories)
end

local function resolve_image_path(relative_path)
  if vim.fn.fnamemodify(relative_path, ":p") == relative_path then
    local normalized = vim.fs.normalize(relative_path)
    local realpath = vim.loop.fs_realpath(normalized)

    if vim.fn.filereadable(normalized) == 1 or realpath then
      return realpath or normalized
    end

    return nil, { normalized }
  end

  local buffer_directory = vim.fn.expand("%:p:h")
  local direct_candidates = dedupe_paths({
    vim.fs.joinpath(buffer_directory, relative_path),
    vim.fs.joinpath(get_vimtex_root() or "", relative_path),
    vim.fs.joinpath(vim.fn.getcwd(), relative_path),
  })
  local candidates = {}

  for _, project_directory in ipairs(project_directories()) do
    table.insert(direct_candidates, vim.fs.joinpath(project_directory, relative_path))
  end

  for _, candidate in ipairs(dedupe_paths(direct_candidates)) do
    vim.list_extend(candidates, image_path_variants(candidate))
  end

  for _, graphics_directory in ipairs(get_graphicspath_directories()) do
    for _, relative_variant in ipairs(image_path_variants(relative_path)) do
      table.insert(candidates, vim.fs.joinpath(graphics_directory, relative_variant))
    end
  end

  candidates = dedupe_paths(candidates)

  for _, candidate in ipairs(candidates) do
    if vim.fn.filereadable(candidate) == 1 then
      return vim.loop.fs_realpath(candidate) or candidate
    end
  end

  return nil, candidates
end

local function clean_cfile_path(path)
  if not path or path == "" then
    return nil
  end

  return path:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^[{(%[]+", ""):gsub("[})%],;:]+$", "")
end

local function resolve_cfile_image_path()
  local cfile = clean_cfile_path(vim.fn.expand("<cfile>"))

  if not cfile or not has_image_extension(cfile) then
    return nil
  end

  local fullpath = resolve_image_path(cfile)
  if fullpath then
    return fullpath
  end

  local found = vim.fn.findfile(cfile, vim.o.path)
  if found and found ~= "" then
    return vim.loop.fs_realpath(found) or vim.fn.fnamemodify(found, ":p")
  end
end

function M.is_supported_image_path(path)
  return has_image_extension(path)
end

function M.open_excalidraw_in_preview(path)
  local fullpath = vim.loop.fs_realpath(path) or vim.fs.normalize(path)

  if vim.fn.filereadable(fullpath) ~= 1 then
    vim.notify("Excalidraw-Datei nicht gefunden:\n" .. fullpath, vim.log.levels.ERROR)
    return
  end

  if vim.fn.executable("excalidraw") ~= 1 then
    vim.notify("Excalidraw-CLI nicht im PATH gefunden.", vim.log.levels.ERROR)
    return
  end

  local output = vim.fn.tempname() .. ".png"

  vim.system({
    "excalidraw",
    "render",
    fullpath,
    "--out",
    output,
  }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Excalidraw-Rendering fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      M.open_path_in_preview(output)
    end)
  end)
end

function M.open_path_in_preview(path)
  local fullpath = vim.loop.fs_realpath(path) or vim.fs.normalize(path)

  if vim.fn.filereadable(fullpath) ~= 1 then
    vim.notify("Bilddatei nicht gefunden:\n" .. fullpath, vim.log.levels.ERROR)
    return
  end

  vim.system({
    "open",
    "-a",
    "Preview",
    fullpath,
  }, {
    text = true,
  }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify(
          "Bild konnte nicht geöffnet werden:\n" .. fullpath .. "\n" .. (result.stderr or ""),
          vim.log.levels.ERROR
        )
      end)
      return
    end

    vim.defer_fn(function()
      vim.system({
        "osascript",
        "-e",
        [[
          tell application "Preview" to activate
          delay 0.2
          tell application "System Events"
            keystroke "A" using {shift down, command down}
          end tell
        ]],
      })
    end, 300)
  end)
end

function M.open_path_in_oil(path)
  local fullpath = vim.loop.fs_realpath(path) or vim.fs.normalize(path)

  if vim.fn.filereadable(fullpath) ~= 1 then
    vim.notify("Bilddatei nicht gefunden:\n" .. fullpath, vim.log.levels.ERROR)
    return
  end

  local directory = vim.fn.fnamemodify(fullpath, ":p:h")
  local filename = vim.fn.fnamemodify(fullpath, ":t")
  local oil = require("oil")
  local oil_url = oil.get_url_for_path(directory)

  require("oil.view").set_last_cursor(oil_url, filename)
  oil.open(directory)
end

function M.open_current_image_in_oil()
  local allowed_filetypes = {
    tex = true,
    plaintex = true,
    markdown = true,
    typst = true,
  }

  if not allowed_filetypes[vim.bo.filetype] then
    vim.notify("Bildpfad in Oil ist nur in TeX- und Markdown-Dateien aktiv.", vim.log.levels.INFO)
    return
  end

  local relative_path = get_path_from_line()
  if relative_path then
    local fullpath = resolve_image_path(relative_path)

    if fullpath then
      M.open_path_in_oil(fullpath)
      return
    end
  end

  local cfile_fullpath = resolve_cfile_image_path()

  if cfile_fullpath then
    M.open_path_in_oil(cfile_fullpath)
    return
  end

  vim.notify("Kein auflösbarer PNG- oder JPEG-Pfad unter dem Cursor gefunden.", vim.log.levels.WARN)
end

local function open_image_in_preview()
  -- In Oil nichts ausführen.
  if vim.bo.filetype == "oil" then
    return
  end

  -- Nur in LaTeX und Markdown aktiv.
  local allowed_filetypes = {
    tex = true,
    plaintex = true,
    markdown = true,
    typst = true,
  }

  if not allowed_filetypes[vim.bo.filetype] then
    vim.notify("Bildvorschau ist nur in TeX- und Markdown-Dateien aktiv.", vim.log.levels.INFO)
    return
  end

  local relative_path = get_path_from_line()

  if not relative_path then
    vim.notify("Kein PNG- oder JPEG-Pfad in geschweiften Klammern gefunden.", vim.log.levels.WARN)
    return
  end

  local fullpath, checked_paths = resolve_image_path(relative_path)

  if not fullpath then
    vim.notify("Bilddatei nicht gefunden. Geprüft:\n" .. table.concat(checked_paths, "\n"), vim.log.levels.ERROR)
    return
  end

  M.open_path_in_preview(fullpath)
end

M.open_image_in_preview = open_image_in_preview

local function set_image_keymaps(bufnr)
  local opts = {
    buffer = bufnr,
    silent = true,
  }

  vim.keymap.set(
    "n",
    "ga",
    open_image_in_preview,
    vim.tbl_extend("force", opts, {
      desc = "Bildpfad in Preview öffnen",
    })
  )

  vim.keymap.set(
    "n",
    "gp",
    function()
      M.open_current_image_in_oil()
    end,
    vim.tbl_extend("force", opts, {
      desc = "Bildpfad in Oil anzeigen",
    })
  )
end

M.set_image_keymaps = set_image_keymaps

set_image_keymaps(0)

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "markdown", "typst" },
  callback = function(event)
    set_image_keymaps(event.buf)
  end,
})

return setmetatable(M, {
  __call = function()
    return open_image_in_preview()
  end,
})
