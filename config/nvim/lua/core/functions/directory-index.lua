local M = {}

local cache_dir = vim.fn.stdpath("cache")

-- ---------------------------------------------------------
-- Index-Quellen
-- ---------------------------------------------------------

local sources = {
  icloud = {
    label = "iCloud",

    root = vim.fs.joinpath(vim.fn.expand("~"), "Library", "Mobile Documents", "com~apple~CloudDocs"),

    cache_file = vim.fs.joinpath(cache_dir, "icloud-directories.txt"),

    fd_args = {
      "--type",
      "d",
      "--exclude",
      ".git",
      "--hidden",
      "--no-ignore",
      "--strip-cwd-prefix",
    },
  },

  dracoon = {
    label = "DRACOON",

    root = vim.fs.joinpath(
      vim.fn.expand("~"),
      "Library",
      "Application Support",
      "DRACOON",
      "Volumes.noindex",
      "DRACOON.localized"
    ),

    cache_file = vim.fs.joinpath(cache_dir, "dracoon-directories.txt"),

    fd_args = {
      "--type",
      "d",
      "--exclude",
      ".git",
      "--hidden",
      "--no-ignore",
      "--strip-cwd-prefix",
    },
  },

  local_files = {
    label = "Local",

    root = vim.fn.expand("~"),

    cache_file = vim.fs.joinpath(cache_dir, "local-directories.txt"),

    -- Bei Local:
    --   keine versteckten Verzeichnisse
    --   keine ~/Library
    --   keine .git-Verzeichnisse
    fd_args = {
      "--type",
      "d",
      "--exclude",
      ".git",
      "--exclude",
      "Library",
      "--strip-cwd-prefix",
    },
  },
}

-- Verhindert mehrere parallele Refreshs
-- derselben Quelle.
local refresh_running = {}

-- ---------------------------------------------------------
-- Quelle ermitteln
-- ---------------------------------------------------------

local function get_source(name)
  local source = sources[name]

  if not source then
    vim.notify("Unbekannter Verzeichnisindex: " .. tostring(name), vim.log.levels.ERROR)
    return nil
  end

  return source
end

-- ---------------------------------------------------------
-- Öffentliche Informationen
-- ---------------------------------------------------------

function M.get_root(name)
  local source = get_source(name)

  if not source then
    return nil
  end

  return source.root
end

function M.get_label(name)
  local source = get_source(name)

  if not source then
    return nil
  end

  return source.label
end

-- ---------------------------------------------------------
-- Cache lesen
-- ---------------------------------------------------------

function M.read(name)
  local source = get_source(name)

  if not source then
    return nil
  end

  local file = io.open(source.cache_file, "r")

  if not file then
    return nil
  end

  local dirs = {}

  for line in file:lines() do
    if line ~= "" then
      table.insert(dirs, line)
    end
  end

  file:close()

  return dirs
end

-- ---------------------------------------------------------
-- Cache aktualisieren
-- ---------------------------------------------------------

function M.refresh(name)
  local source = get_source(name)

  if not source then
    return
  end

  if refresh_running[name] then
    vim.notify(source.label .. "-Cache wird bereits aktualisiert", vim.log.levels.INFO)
    return
  end

  if vim.fn.isdirectory(source.root) ~= 1 then
    vim.notify(source.label .. "-Verzeichnis nicht gefunden:\n" .. source.root, vim.log.levels.ERROR)
    return
  end

  refresh_running[name] = true

  vim.notify(source.label .. "-Cache wird aktualisiert …", vim.log.levels.INFO)

  -- fd-Kommando aus den Argumenten der jeweiligen
  -- Quelle zusammensetzen.
  local command = { "fd" }

  vim.list_extend(command, source.fd_args)

  vim.system(command, {
    cwd = source.root,
    text = true,
  }, function(result)
    vim.schedule(function()
      refresh_running[name] = false

      if result.code ~= 0 then
        vim.notify(
          source.label .. "-Cache konnte nicht aktualisiert werden:\n" .. (result.stderr or ""),
          vim.log.levels.ERROR
        )
        return
      end

      local dirs = {}

      for line in (result.stdout or ""):gmatch("[^\r\n]+") do
        if line ~= "" then
          table.insert(dirs, line)
        end
      end

      table.sort(dirs)

      -- Cache-Verzeichnis sicherstellen
      vim.fn.mkdir(cache_dir, "p")

      -- Erst temporär schreiben.
      -- Dadurch bleibt der alte Cache erhalten,
      -- falls beim Schreiben etwas schiefgeht.
      local temp_file = source.cache_file .. ".tmp"

      local file, err = io.open(temp_file, "w")

      if not file then
        vim.notify("Cache konnte nicht geschrieben werden:\n" .. tostring(err), vim.log.levels.ERROR)
        return
      end

      for _, dir in ipairs(dirs) do
        file:write(dir .. "\n")
      end

      file:close()

      local ok, rename_err = os.rename(temp_file, source.cache_file)

      if not ok then
        vim.notify("Cache konnte nicht ersetzt werden:\n" .. tostring(rename_err), vim.log.levels.ERROR)
        return
      end

      vim.notify(string.format("%s-Cache aktualisiert: %d Verzeichnisse", source.label, #dirs), vim.log.levels.INFO)
    end)
  end)
end

-- ---------------------------------------------------------
-- Cache-Aktualisierung auswählen
-- ---------------------------------------------------------

function M.choose_refresh()
  vim.ui.select({
    "iCloud",
    "DRACOON",
    "Local",
    "Alle",
  }, {
    prompt = "Verzeichnisindex aktualisieren:",
  }, function(choice)
    if choice == "iCloud" then
      M.refresh("icloud")
    elseif choice == "DRACOON" then
      M.refresh("dracoon")
    elseif choice == "Local" then
      M.refresh("local_files")
    elseif choice == "Alle" then
      M.refresh("icloud")
      M.refresh("dracoon")
      M.refresh("local_files")
    end
  end)
end

-- ---------------------------------------------------------
-- Command
-- ---------------------------------------------------------

vim.api.nvim_create_user_command("DirectoryIndexUpdate", function()
  M.choose_refresh()
end, {
  desc = "Verzeichnisindizes aktualisieren",
})

return M
