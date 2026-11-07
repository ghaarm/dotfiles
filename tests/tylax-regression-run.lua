-- Run with TYLAX_FIXTURE_DIR pointing at a directory containing a .tex file.
package.path = "config/nvim/lua/?.lua;config/nvim/lua/?/init.lua;" .. package.path
local dir = assert(vim.env.TYLAX_FIXTURE_DIR, "TYLAX_FIXTURE_DIR fehlt")
local entry = assert(vim.env.TYLAX_FIXTURE_TEX, "TYLAX_FIXTURE_TEX fehlt")
package.loaded.oil = {
  get_cursor_entry = function() return { type = "file", name = entry } end,
  get_current_dir = function() return dir end,
}
package.loaded["oil.actions"] = { refresh = { callback = function() end } }
local notices = {}
vim.notify = function(message, level)
  notices[#notices + 1] = { message = message, level = level }
  io.stderr:write(message .. "\n")
end
require("core.functions.tylax-typst-latex-converter").latex_to_typst()
local output = dir .. "/" .. entry:gsub("%.tex$", ".typ")
assert(vim.wait(30000, function() return vim.uv.fs_stat(output) ~= nil end, 50), "Keine Typst-Ausgabe")
local generated = assert(io.open(output, "rb"))
local content = generated:read("*a")
generated:close()
assert(not content:find("{{INPUT:", 1, true), "Nicht ersetzte Typst-Einfügemarke")
for _, notice in ipairs(notices) do
  assert(notice.level ~= vim.log.levels.ERROR, notice.message)
end
print(output)
