-- Run: nvim --headless -u NONE -i NONE -l config/nvim/tests/latex-comment-figures-compile.lua
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = config_dir .. "/lua/?.lua;" .. package.path
vim.opt.shortmess:append("W")

local source = { "\\begin{figure}", "\\includegraphics{image}", "\\end{figure}" }
local events, messages, builds, sent
local checks = 0
local function check(value, message)
  assert(value, message)
  checks = checks + 1
end
local function note(event)
  events[#events + 1] = event
end

-- Mock compilers and LSP transport; use actual Neovim commands and file writes.
vim.cmd([[
function! TestCompilerRunning() dict abort
  return self.running
endfunction
]])
vim.api.nvim_create_user_command("VimtexStop", function()
  note("stop")
  check(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), source), "Stop before commenting")
  vim.cmd("let b:vimtex.compiler.running = 0")
end, {})
vim.fn.executable = function() return 1 end
vim.system = function(cmd)
  note("build")
  builds[#builds + 1] = cmd
  return {}
end
vim.notify = function(message)
  messages[#messages + 1] = message
end

local function transport(name)
  return function(method, params)
    sent[#sent + 1] = { name, method, params.textDocument.uri }
    return true
  end
end
local texlab_notify = transport("texlab")
local other_notify = transport("other")
local texlab = { rpc = { notify = texlab_notify } }
local other = { rpc = { notify = other_notify } }
vim.lsp.get_clients = function(filter)
  if not filter then return {} end
  check(filter.name == "texlab" and filter.bufnr == 0, "Only current buffer's Texlab clients")
  return { texlab }
end

local group = vim.api.nvim_create_augroup("TestPublicBuild", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  callback = function()
    note("write")
    local params = { textDocument = { uri = vim.uri_from_bufnr(0) } }
    texlab.rpc.notify("textDocument/didChange", params)
    texlab.rpc.notify("textDocument/didSave", params)
    other.rpc.notify("textDocument/didSave", params)
    texlab.rpc.notify("textDocument/didSave", { textDocument = { uri = "file:///other.tex" } })
  end,
})

local function setup(active)
  vim.cmd("enew!")
  vim.api.nvim_buf_set_name(0, vim.fn.tempname() .. ".tex")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, source)
  events, messages, builds, sent = {}, {}, {}, {}
  texlab.rpc.notify = texlab_notify
  if active ~= nil and active ~= false then
    vim.cmd("let b:vimtex = {'compiler': {'running': " .. active .. ", 'is_running': function('TestCompilerRunning')}}")
  end
  dofile(config_dir .. "/lua/core/functions/latex-comment-figures-compile.lua")
end

for _, trigger in ipairs({ "LatexCommentCompile", ",lx", ",lz" }) do
  setup(1)
  if trigger == "LatexCommentCompile" then
    vim.cmd.LatexCommentCompile()
  else
    -- The test has no localleader setting, so find the mapping by description.
    local description = trigger == ",lx" and "Build public PDF without commented figures and tables"
      or "Build public PDF without commented figures and tables using Ghostscript"
    local callback
    for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
      if mapping.desc == description then callback = mapping.callback end
    end
    assert(callback, "Public build mapping missing")
    callback()
  end
  check(vim.deep_equal(events, { "stop", "write", "build" }), "Stop, save, then build")
  check(#builds == 1 and builds[1][1] == "latexmk", "One public compiler starts")
  check(vim.fn.eval("b:vimtex.compiler.running") == 0, "VimTeX remains stopped")
  local saved = vim.fn.readfile(vim.api.nvim_buf_get_name(0))
  check(saved[1] == "% LATEX_FLOAT_OFF " .. source[1], "File saved with hidden figures")
  check(#sent == 3, "Only target Texlab didSave suppressed")
  check(sent[1][2] == "textDocument/didChange" and sent[2][1] == "other"
    and sent[3][3] == "file:///other.tex", "Changes, other clients and other files forwarded")
  check(texlab.rpc.notify == texlab_notify, "Transport restored")
  texlab.rpc.notify("textDocument/didSave", { textDocument = { uri = vim.uri_from_bufnr(0) } })
  check(#sent == 4, "Subsequent saves notify Texlab normally")
end

for _, active in ipairs({ 0, false }) do
  setup(active)
  vim.cmd.LatexCommentCompile()
  check(vim.deep_equal(events, { "write", "build" }), "No stop needed when idle or without VimTeX")
end

setup(1)
local failure = vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function() error("simulated write failure") end,
})
vim.cmd.LatexCommentCompile()
check(#builds == 0, "No build after write failure")
check(texlab.rpc.notify == texlab_notify, "Transport restored after write failure")
check(table.concat(messages):find("simulated write failure", 1, true), "Write failure reported")
vim.api.nvim_del_autocmd(failure)

setup(1)
vim.api.nvim_create_user_command("VimtexStop", function() error("simulated stop failure") end, { force = true })
vim.cmd.LatexCommentCompile()
check(#builds == 0 and #events == 0, "Stop failure prevents save and build")
check(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), source), "Stop failure preserves source")

setup(1)
vim.api.nvim_create_user_command("VimtexStop", function() end, { force = true })
vim.wait = function() return false end
vim.cmd.LatexCommentCompile()
check(#builds == 0 and #events == 0, "Stop timeout prevents save and build")
check(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), source), "Stop timeout preserves source")
check(table.concat(messages):find("nicht rechtzeitig beendet", 1, true), "Stop timeout reported")

print(checks .. " assertions passed")
