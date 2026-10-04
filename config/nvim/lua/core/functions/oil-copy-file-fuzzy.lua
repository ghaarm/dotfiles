-- ~/.config/nvim/lua/core/functions/oil_copy_fuzzy.lua
--
-- braucht:
--   oil.nvim
--   telescope.nvim
--   fd
--
-- iCloud:
--   <leader>cc = Copy
--   <leader>cm = Copy + Ziel öffnen
--
-- DRACOON:
--   <leader>cz = Copy
--   <leader>cx = Copy + Ziel öffnen
--
-- Local:
--   <leader>cl = Copy
--   <leader>co = Copy + Ziel öffnen
--
-- Index:
--   <leader>cr = Index aktualisieren

local M = {}

local directory_index = require("core.functions.directory-index")

-- ---------------------------------------------------------
-- Oil: Datei unter Cursor
-- ---------------------------------------------------------

local function get_oil_source()
  local oil = require("oil")

  local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()

  if not entry or not dir then
    vim.notify("Keine Datei unter Cursor", vim.log.levels.WARN)
    return nil
  end

  return {
    name = entry.name,
    source = vim.fs.joinpath(dir, entry.name),
  }
end

-- ---------------------------------------------------------
-- Telescope-Picker
-- ---------------------------------------------------------

local function select_target_dir(index_name, callback)
  local dirs = directory_index.read(index_name)
  local root = directory_index.get_root(index_name)
  local label = directory_index.get_label(index_name)

  if not root or not label then
    return
  end

  if not dirs or #dirs == 0 then
    vim.notify("Kein " .. label .. "-Cache vorhanden.\n" .. "Zuerst <leader>cr ausführen.", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = label .. " Zielverzeichnis",

      finder = finders.new_table({
        results = dirs,
      }),

      sorter = conf.generic_sorter({}),

      previewer = false,

      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()

          if not selection then
            return
          end

          actions.close(prompt_bufnr)

          local relative_dir = selection.value or selection[1]

          if not relative_dir then
            vim.notify("Zielverzeichnis konnte nicht ermittelt werden", vim.log.levels.ERROR)
            return
          end

          local target_dir = vim.fs.normalize(vim.fs.joinpath(root, relative_dir))

          callback(target_dir)
        end)

        return true
      end,
    })
    :find()
end

-- ---------------------------------------------------------
-- Kopieren
-- ---------------------------------------------------------

local function copy_to_fuzzy_dir(index_name, change_dir)
  local source_info = get_oil_source()

  if not source_info then
    return
  end

  select_target_dir(index_name, function(target_dir)
    local target = vim.fs.joinpath(target_dir, source_info.name)

    vim.system({
      "cp",
      "-R",
      source_info.source,
      target,
    }, {
      text = true,
    }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("Kopieren fehlgeschlagen:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
          return
        end

        vim.notify("Kopiert nach:\n" .. target_dir, vim.log.levels.INFO)

        if change_dir then
          vim.cmd.enew()
          require("oil").open(target_dir)
        end
      end)
    end)
  end)
end

-- ---------------------------------------------------------
-- iCloud
-- ---------------------------------------------------------

function M.copy_icloud()
  copy_to_fuzzy_dir("icloud", false)
end

function M.copy_icloud_and_cd()
  copy_to_fuzzy_dir("icloud", true)
end

-- ---------------------------------------------------------
-- DRACOON
-- ---------------------------------------------------------

function M.copy_dracoon()
  copy_to_fuzzy_dir("dracoon", false)
end

function M.copy_dracoon_and_cd()
  copy_to_fuzzy_dir("dracoon", true)
end

-- ---------------------------------------------------------
-- Local
-- ---------------------------------------------------------

function M.copy_local()
  copy_to_fuzzy_dir("local_files", false)
end

function M.copy_local_and_cd()
  copy_to_fuzzy_dir("local_files", true)
end

-- ---------------------------------------------------------
-- Oil-Keymaps
-- ---------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",

  callback = function(args)
    -- Index aktualisieren
    vim.keymap.set("n", "<leader>cr", function()
      directory_index.choose_refresh()
    end, {
      buffer = args.buf,
      desc = "Oil: Refresh directory index",
    })

    -- iCloud
    vim.keymap.set("n", "<leader>cc", function()
      M.copy_icloud()
    end, {
      buffer = args.buf,
      desc = "Oil: Copy fuzzy iCloud",
    })

    vim.keymap.set("n", "<leader>cm", function()
      M.copy_icloud_and_cd()
    end, {
      buffer = args.buf,
      desc = "Oil: Copy + open target iCloud",
    })

    -- DRACOON
    vim.keymap.set("n", "<leader>cz", function()
      M.copy_dracoon()
    end, {
      buffer = args.buf,
      desc = "Oil: Copy fuzzy DRACOON",
    })

    vim.keymap.set("n", "<leader>cx", function()
      M.copy_dracoon_and_cd()
    end, {
      buffer = args.buf,
      desc = "Oil: Copy + open target DRACOON",
    })

    -- Local
    vim.keymap.set("n", "<leader>cl", function()
      M.copy_local()
    end, {
      buffer = args.buf,
      desc = "Oil: Copy fuzzy Local",
    })

    vim.keymap.set("n", "<leader>co", function()
      M.copy_local_and_cd()
    end, {
      buffer = args.buf,
      desc = "Oil: Copy + open target Local",
    })
  end,
})

return M
