vim.g.mapleader = " " -- weil sonst die functions.lua keinen leader hat, der wird erst in den keybindings gesetzt
vim.g.maplocalleader = ","

require("core")

-- Set the Python 3 host program to the virtual environment Pythoni
-- für vimtex live preview, brauche eine virtuelle Umgebung damit pynvim läuft
vim.g.python3_host_prog = "/Users/g/neovim-venv/bin/python3"

-- vim.g.EasyClipUseGlobalPasteToggle = 0 -- weil es sonst einen error mit easyclip gibt

-- Verhindert Buffer-Konflikte (E95) bei :restart und Possession
vim.opt.sessionoptions:remove("buffers")
--
-- Cargo-Programme verfügbar machen (z. B. Tylax)
local cargo_bin = vim.fn.expand("~/.cargo/bin")

if not vim.env.PATH:find(cargo_bin, 1, true) then
  vim.env.PATH = cargo_bin .. ":" .. vim.env.PATH
end

require("lazy_bootstrap")
