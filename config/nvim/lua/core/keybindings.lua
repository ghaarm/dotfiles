vim.g.mapleader = " "
-- Deaktivieren der Pfeiltasten im normalen Modus
-- vim.api.nvim_set_keymap("n", "<Up>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<Down>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<Left>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<Right>", "<NOP>", { noremap = true, silent = true })
--
-- -- Deaktivieren der Pfeiltasten im Einfügemodus
-- vim.api.nvim_set_keymap("i", "<Up>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "<Down>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "<Left>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "<Right>", "<NOP>", { noremap = true, silent = true })
--
-- -- Deaktivieren der Pfeiltasten im visuellen Modus
-- vim.api.nvim_set_keymap("v", "<Up>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "<Down>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "<Left>", "<NOP>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "<Right>", "<NOP>", { noremap = true, silent = true })
--
--
vim.keymap.set("n", "<Down>", "gj", {
  noremap = true,
  silent = true,
  desc = "Down by visual line",
})

vim.keymap.set("n", "<Up>", "gk", {
  noremap = true,
  silent = true,
  desc = "Up by visual line",
})
--
-- alles markieren
vim.api.nvim_set_keymap("n", "<D-a>", "ggVG$", { noremap = true, silent = true })

-- control r für redo umlegen auf cmd r
-- vim.api.nvim_set_keymap("n", "<D-r>", "<C-r>", { noremap = true, silent = true })

-- Datei speichern mit cmd + s im normal modus
vim.api.nvim_set_keymap("n", "<D-s>", ":w<CR>", { noremap = true, silent = true })

-- Datei speichern mit cmd + s im insert modus
vim.api.nvim_set_keymap("i", "<D-s>", "<C-\\><C-n>:w<CR>", { noremap = true, silent = true })

-- markierten Bereich kopieren im visuellen Modus
vim.api.nvim_set_keymap("v", "<D-c>", "y", { noremap = true, silent = true })

-- im insert mode mit alt del das folgende Wort löschen, fängt die Einstellung von Kitty ab
vim.api.nvim_set_keymap("i", "\x1bd", "<C-o>dW", { noremap = true, silent = true })

-- nicht in den insertmodus wechseln ibei o oder O
vim.api.nvim_set_keymap("n", "o", "o<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "O", "O<Esc>", { noremap = true, silent = true })

-- auch mit cmd + c kopieren können und nicht nur yank
vim.api.nvim_set_keymap("v", "<D-c>", '"+y', { noremap = true, silent = true })

-- shift K um zeile zu trennen und leader K um alte K Funktion zu erhalten
-- vim.keymap.set('n', 'K', [[:silent keeppatterns s/\%#/\r/<CR>]], { noremap = true, silent = true }) -- ohne reindent
-- mit reindent
vim.keymap.set("n", "K", [[:silent keeppatterns s/\%#/\r/<CR>==]], { noremap = true, silent = true })

vim.keymap.set("n", "<leader>K", function()
  vim.cmd("normal! K") -- Original: keywordprg (z.B. man/:help) fürs Wort unter Cursor
end, { noremap = true, silent = true, desc = "Wie 'K': keywordprg-Doku (man/:help) fürs Wort unter Cursor" })
-- vim.keymap.set("n", "<leader>K", function()
--   vim.cmd("normal! K") -- führt die ursprüngliche K-Aktion aus
-- end, { noremap = true, silent = true })

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jj" })
keymap.set("i", "jl", "<ESC>", { desc = "Exit insert mode with jj" })
-- keymap.set("i", "tn", "<ESC>", { desc = "Exit insert mode with jj" })

keymap.set("n", "<leader><leader>n", ":source $MYVIMRC<CR>", { desc = "Reload Neovim Config" })

---------------------------------------------------------------------------
-- NAVIGATION
---------------------------------------------------------------------------
vim.keymap.set("n", "<leader><leader>a", ":Alpha<CR>", { desc = "Return to Alpha Dashboard" })

vim.keymap.set("n", "<leader>bn", ":bn<CR>", { desc = "Nächster Buffer" })
vim.keymap.set("n", "<leader>bp", ":bp<CR>", { desc = "Vorheriger Buffer" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>vs", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>hs", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>en", "<cmd>enew<cr>", { desc = "New empty buffer" })
keymap.set("n", "<leader>vn", "<cmd>vnew<cr>", { desc = "New empty vertical split" })
keymap.set("n", "<leader>hn", "<cmd>new<cr>", { desc = "New empty horizontal split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
keymap.set("n", "<leader>xa", "<cmd>xa<cr>", { desc = "Save all and exit" })
keymap.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete buffer" })

keymap.set("n", "<leader>dt", "<cmd>diffthis<cr>", { desc = "diff this" })
keymap.set("n", "<leader>do", "<cmd>diffoff!<cr>", { desc = "turn diff OFF" })
keymap.set("n", "<leader>dg", "<cmd>diffget<cr>", { desc = "get change from other window" })
keymap.set("n", "<leader>du", "<cmd>diffput<cr>", { desc = "put change to other window" })
keymap.set("n", "<leader>dq", "<cmd>windo diffoff!<cr>", { desc = "turn diff off in all windows" })
keymap.set("n", "<leader>dn", "]c", { desc = "next diff" })
keymap.set("n", "<leader>dp", "[c", { desc = "previous diff" })

-- Vimtex-specific keybindings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- Set local leader key for tex files
    vim.b.mapleader = "\\"
    -- Set Vimtex TOC toggle keybinding
    keymap.set("n", "<localleader>i", "<cmd>VimtexTocToggle<CR>", { buffer = true, desc = "Toggle Vimtex TOC" })
  end,
})

-- Setze eine Tastenkombination zum Umschalten der Zeilennummerierung
vim.api.nvim_set_keymap("n", "<Leader>lr", ":set relativenumber!<CR>", { noremap = true, silent = true })

-- Telescope-specific keybindings, sind in telescope.lua definiert
-- keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
-- keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
-- keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
-- keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
-- keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
-- keymap.set("i", "<D-i>", "<cmd>Telescope bibtex<cr>", { desc = "Open Telescope BibTeX search" }) -- D steht für die Command taste

-- Scrollen vom Primagen damit Cursor immer in der Mitte, dann neoscroll entfernen

vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- alt + backspace soll word löschen und dann insert modus machen

vim.api.nvim_set_keymap("i", "<M-BS>", "<C-w>", { noremap = true, silent = true })
-- cmd + backspace löscht ganze Zeile
vim.api.nvim_set_keymap("i", "<D-BS>", "<C-u>", { noremap = true, silent = true })
--
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Ersatz für vim-easy clip, ausschneiden mit m und gm für marks
-- Delete / change to black hole by default
vim.keymap.set({ "n", "x" }, "d", '"_d', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "c", '"_c', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "x", '"_x', { noremap = true, silent = true })

vim.keymap.set("n", "dd", '"_dd', { noremap = true, silent = true })
vim.keymap.set("n", "D", '"_D', { noremap = true, silent = true })
vim.keymap.set("n", "C", '"_C', { noremap = true, silent = true })
vim.keymap.set("n", "s", '"_s', { noremap = true, silent = true })
vim.keymap.set("n", "S", '"_S', { noremap = true, silent = true })

-- damit bei Makros nicht aus dem Systemclipboard gepasted wird, jetzt wird ausschnitt in z eingefügt und von dort gepasted
vim.keymap.set("x", "m", '"zd', { noremap = true, silent = true })
vim.keymap.set("n", "m", '"zx', { noremap = true, silent = true })
vim.keymap.set("n", "mm", '"zdd', { noremap = true, silent = true })

vim.keymap.set("n", "zp", '"zp', { noremap = true, silent = true })
vim.keymap.set("n", "zP", '"zP', { noremap = true, silent = true })
vim.keymap.set("x", "zp", '"_d"zP', { noremap = true, silent = true })
------------
-- Visual:
vim.keymap.set("x", "<leader>mm", '"+d', { noremap = true, silent = true }) -- schneidet ins Systemclipboard aus sonst Register z
vim.keymap.set("x", "p", '"_dP', { noremap = true, silent = true }) --  auch wenn dein Yank im System-Clipboard landet, überschreibt ein normales p über einer Visual-Auswahl oft den Registerinhalt durch das Ersetzen der Auswahl. Mit "_dP verhinderst du genau das.

-- 3) Marks: m{a-zA-Z} -> gm{a-zA-Z}, `m` frei machen
vim.keymap.set("n", "gm", "m", { noremap = true, silent = true })
vim.keymap.set("n", "gM", "M", { noremap = true, silent = true }) -- optional: "M" (Middle of screen) bleibt sonst, je nach Geschmack
---
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--- spell
vim.keymap.set("n", "<leader>sg", function()
  vim.opt.spelllang = { "de" }
end, { desc = "spell: DE" })
vim.keymap.set("n", "<leader>sn", function()
  vim.opt.spelllang = { "en" }
end, { desc = "spell: EN" })
vim.keymap.set("n", "<leader>sb", function()
  vim.opt.spelllang = { "de", "en" }
end, { desc = "spell: DE+EN" })
------------------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------
-- aus functions.lua um Datei im Finder zu öffnen
vim.api.nvim_set_keymap("n", "<leader>o", ":lua OpenInFinder()<CR>", { noremap = true, silent = true })

-- tex und ctrl key für .*\.tex
vim.keymap.set("c", "<C-k>", function()
  local cmd = vim.fn.getcmdline()
  local typ = vim.fn.getcmdtype()

  if (typ == "/" or typ == "?") and cmd:sub(-3) == "tex" then
    return "<BS><BS><BS>.*\\.tex"
  end
  return "<C-k>"
end, { expr = true })
---
-- Keymaps um direkt zum Tab zu gehen
vim.keymap.set("n", "<leader><leader>1", "1gt", { desc = "Tab 1" })
vim.keymap.set("n", "<leader><leader>2", "2gt", { desc = "Tab 2" })
vim.keymap.set("n", "<leader><leader>3", "3gt", { desc = "Tab 3" })
vim.keymap.set("n", "<leader><leader>4", "4gt", { desc = "Tab 4" })
vim.keymap.set("n", "<leader><leader>5", "5gt", { desc = "Tab 5" })
--- HACK: How I navigate between buffers in neovim
-- https://youtu.be/ldfxEda_mzc
--
-- I'm switching from bufexplorer to telescope buffers as I get a file preview,
-- that's basically the main benefit lamw25wmal
-- vim.keymap.set("n", "<S-h>", function()
--   require("telescope.builtin").buffers(require("telescope.themes").get_ivy({
--     sort_mru = true,
--     -- -- Sorts current and last buffer to the top and selects the lastused (default: false)
--     -- -- Leave this at false, otherwise when put in normal mode, the buffer
--     -- -- below is selected, not the one at the top
--     sort_lastused = false,
--     initial_mode = "normal",
--     -- Pre-select the current buffer
--     -- ignore_current_buffer = false,
--     -- select_current = true,
--     layout_config = {
--       -- Set preview width, 0.7 sets it to 70% of the window width
--       preview_width = 0.45,
--     },
--   }))
-- end, { desc = "[P]Open telescope buffers" }) --
--
-- vim.keymap.set(
--   "n",
--   "<S-h>",
--   "<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode theme=ivy<cr>",
--   { desc = "[P]Open telescope buffers" }
-- )
-- local builtin = require("telescope.builtin")
-- local themes = require("telescope.themes")
--
-- -- ...
--
-- -- ganz unten bei den Keymaps
-- keymap.set("n", "<S-h>", function()
--   builtin.buffers(themes.get_ivy({
--     sort_mru = true,
--     sort_lastused = true,
--     ignore_current_buffer = true,
--     initial_mode = "normal", -- optional
--   }))
-- end, { desc = "[P]Open telescope buffers" })
--
--
