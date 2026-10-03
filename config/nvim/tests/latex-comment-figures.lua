-- Run: nvim --headless -u NONE -i NONE -l config/nvim/tests/latex-comment-figures.lua
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
dofile(config_dir .. "/lua/core/functions/latex-comment-figures.lua")

local function lines(text)
  return vim.split(text, "\n", { plain = true })
end

local function marked(text)
  local result = lines(text)
  for i, line in ipairs(result) do
    local indent, rest = line:match("^(%s*)(.*)$")
    result[i] = indent .. "% LATEX_FLOAT_OFF " .. rest
  end
  return table.concat(result, "\n")
end

local figure = "\\begin{figure}[H]\n  \\includegraphics{image}\n  \\caption{Image}\n\\end{figure}"
local captionof = "\\begin{center}\n  \\begin{minipage}{\\linewidth}\n"
  .. "    \\includegraphics{image}\n    \\captionof{figure}{Image}\n"
  .. "    {\\footnotesize Source\\par}\n  \\end{minipage}\n\\end{center}"
local opening = "\\begin{multicols}{2}"
local closing = "\\end{multicols}"
local function columns(content)
  return opening .. "\n" .. content .. "\n" .. closing
end

local checks = 0
local function expect(expected, label)
  local actual = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  assert(vim.deep_equal(actual, lines(expected)), label .. "\nActual:\n" .. table.concat(actual, "\n"))
  checks = checks + 1
end

local function check(name, original, commented)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines(original))
  vim.cmd.LatexCommentFloats()
  expect(commented, name .. ": comment")
  vim.cmd.LatexCommentFloats()
  expect(commented, name .. ": repeated comment")
  vim.cmd.LatexToggleFloats()
  expect(original, name .. ": toggle restores original")
  vim.cmd.LatexToggleFloats()
  expect(commented, name .. ": toggle comments again")
  vim.cmd.LatexUncommentFloats()
  expect(original, name .. ": explicit restore")
end

-- Each multicols environment keeps its own boundaries. Only environments
-- without active content may be removed, independently of adjacent floats.
check("Empty left columns next to text",
  columns(figure) .. "\n" .. figure .. "\n" .. columns("Text"),
  marked(columns(figure) .. "\n" .. figure) .. "\n" .. columns("Text"))
check("Text next to empty right columns",
  columns("Text") .. "\n" .. figure .. "\n" .. columns(figure),
  columns("Text") .. "\n" .. marked(figure .. "\n" .. columns(figure)))
local all_empty = columns(figure) .. "\n" .. figure .. "\n" .. columns(figure)
check("Separate columns containing only figures", all_empty, marked(all_empty))
local three = columns(figure) .. "\n" .. figure .. "\n" .. columns(figure) .. "\n" .. figure .. "\n" .. columns("Text")
check("Three separate columns preserve text", three,
  marked(columns(figure) .. "\n" .. figure .. "\n" .. columns(figure) .. "\n" .. figure) .. "\n" .. columns("Text"))
check("Text columns on both sides of a float",
  columns("Before") .. "\n" .. figure .. "\n" .. columns("After"),
  columns("Before") .. "\n" .. marked(figure) .. "\n" .. columns("After"))
check("Full-width text after a float",
  columns("Before") .. "\n" .. figure .. "\nFull-width text",
  columns("Before") .. "\n" .. marked(figure) .. "\nFull-width text")
check("Full-width text before a float",
  "Full-width text\n" .. figure .. "\n" .. columns("After"),
  "Full-width text\n" .. marked(figure) .. "\n" .. columns("After"))
local three_columns = "\\begin{multicols}{3}[Heading]\nAfter\n" .. closing
check("Different column counts and heading",
  columns("Before") .. "\n" .. figure .. "\n" .. three_columns,
  columns("Before") .. "\n" .. marked(figure) .. "\n" .. three_columns)
check("Captionof does not consume adjacent column boundaries",
  columns("Before") .. "\n" .. captionof .. "\n" .. columns("After"),
  columns("Before") .. "\n" .. marked(captionof) .. "\n" .. columns("After"))
local table_float = figure:gsub("{figure}", "{table}")
check("Table does not consume adjacent column boundaries",
  columns("Before") .. "\n" .. table_float .. "\n" .. columns("After"),
  columns("Before") .. "\n" .. marked(table_float) .. "\n" .. columns("After"))

local two_figures = columns(figure .. "\n\n\\columnbreak\n\n" .. figure)
check("Figures separated by columnbreak", two_figures, marked(two_figures))
check("Caption inside minipage", captionof, marked(captionof))
check("Keep text in columns", columns("Text\n" .. figure), columns("Text\n" .. marked(figure)))
local protected = "% nicht kommentieren\n" .. figure
check("Keep protected figure", columns(figure .. "\n" .. protected), columns(marked(figure) .. "\n" .. protected))
local nested = columns(columns(figure))
check("Nested empty columns", nested, marked(nested))
local starred = two_figures:gsub("{multicols}", "{multicols*}"):gsub("\\columnbreak", "\\columnbreak[3] %% comment")
check("Starred columns and optional break", starred, marked(starred))
local header = opening .. "[Heading]\n" .. figure .. "\n" .. closing
check("Keep optional heading", header, opening .. "[Heading]\n" .. marked(figure) .. "\n" .. closing)
check("Preserve manual comments", columns("% explanation\n" .. figure), marked(columns("% explanation\n" .. figure)))

-- Existing partial output can be completed without first restoring all figures.
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines(columns(marked(figure) .. "\n\n\\columnbreak\n\n" .. marked(figure))))
vim.cmd.LatexCommentFloats()
expect(marked(two_figures), "Complete partially commented columns")
vim.cmd.LatexUncommentFloats()
expect(two_figures, "Restore partially commented columns")

print(checks .. " assertions passed")
