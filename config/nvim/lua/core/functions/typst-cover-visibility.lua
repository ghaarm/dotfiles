local M = {}

function M.toggle()
  if vim.bo.filetype ~= "typst" then
    vim.notify("Bitte eine Typst-Datei öffnen", vim.log.levels.WARN)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:find("config-methods", 1, true) and line:find("cover:", 1, true) then
      local changed
      if line:find("cover: utils.alpha-changing-cover.with(alpha: 18%)", 1, true) then
        changed = line:gsub("cover: utils%.alpha%-changing%-cover%.with%(alpha: 18%%%)", "cover: hide", 1)
      elseif line:find("cover: utils.semi-transparent-cover", 1, true) then
        changed = line:gsub("cover: utils%.semi%-transparent%-cover", "cover: hide", 1)
      elseif line:find("cover: hide", 1, true) then
        changed = line:gsub("cover: hide", "cover: utils.alpha-changing-cover.with(alpha: 18%%)", 1)
      end
      if changed and changed ~= line then
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, { changed })
        vim.notify("Touying-Cover: " .. (changed:find("alpha-changing", 1, true) and "transparent" or "unsichtbar"))
        return
      end
    end
  end

  local show_end, package_version
  local inside_show = false
  for i, line in ipairs(lines) do
    package_version = package_version or line:match('@preview/touying:([%d%.]+)')
    if line:match("^%s*#show:%s*kn%-vorlage%.with%s*%(") then
      inside_show = true
    elseif inside_show and line:match("^%s*%)") then
      show_end = i
      break
    end
  end
  if not show_end or not package_version then
    vim.notify("Keine Touying-Vorlage mit Paketimport gefunden", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_buf_set_lines(0, show_end, show_end, false, {
    '#import "@preview/touying:' .. package_version .. '": touying-set-config, config-methods, utils',
    '#show: touying-set-config.with(config-methods(cover: utils.alpha-changing-cover.with(alpha: 18%)))',
  })
  vim.notify("Touying-Cover: transparent")
end

vim.api.nvim_create_user_command("TypstToggleCover", M.toggle, { desc = "Touying-Cover transparent/unsichtbar umschalten" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function(args)
    vim.keymap.set("n", "<localleader>vi", M.toggle,
      { buffer = args.buf, silent = true, desc = "Touying-Cover umschalten" })
  end,
})

return M
