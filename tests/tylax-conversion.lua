-- Run: nvim --headless -u NONE -l tests/tylax-conversion.lua
package.path = "config/nvim/lua/?.lua;config/nvim/lua/?/init.lua;" .. package.path
local process = require("core.functions.tylax-processing")
local t2l = vim.fn.executable("t2l") == 1 and "t2l" or vim.fn.expand("~/.cargo/bin/t2l")
assert(vim.fn.executable(t2l) == 1, "t2l fehlt")

local function convert(source)
  local prepared, options = process.prepare(source)
  assert(prepared, options)
  local result = vim.system({ t2l, "-d", "l2t", "-f", "--no-preamble", "--pretty" },
    { stdin = prepared, text = true }):wait()
  assert(result.code == 0, result.stderr)
  return process.postprocess(result.stdout), options
end

local function contains(haystack, needle)
  assert(haystack:find(needle, 1, true), "Fehlt: " .. needle .. "\n" .. haystack)
end

local function absent(haystack, needle)
  assert(not haystack:find(needle, 1, true), "Unerwartet: " .. needle .. "\n" .. haystack)
end

local tex = [[
\documentclass{article}
\usepackage{fancyhdr}
\title{Testtitel}
\begin{document}
\maketitle
\tableofcontents
\listoffigures
\hypersetup{linkcolor=red!70!black, urlcolor=blue}
\section{Kernpunkte ()}\label{sec:Kernpunkte}
Bei \ignore{≥}$\geq$ 800 und \ignore{≤}$\leq$ 15.
\begin{itemize}
\item[-] Außen
  \begin{itemize}
  \item[-] Innen
  \end{itemize}
\end{itemize}
Abb. \ref{fig:Eine, Abbildung} und Abschnitt \ref{sec:Kernpunkte}.
\footcite[449]{zaloga2005MythGastricResidual}
\footnote{\cite{zaloga2005MythGastricResidual}, S. 450}
\begin{multicols}{2}
\begin{figure}[H]
\includegraphics[width=0.5\linewidth]{bild.png}
\caption{Eine Abbildung\footnote{\cite{zaloga2005MythGastricResidual}, S. 449}}
\label{fig:Eine Abbildung}
\end{figure}
\end{multicols}
\begin{multicols}{2}
\begin{figure}[H]
\includegraphics[width=\linewidth]{breit.png}
\caption{Breite Abbildung}
\end{figure}
\end{multicols}
\end{document}
]]
local output, options = convert(tex)
assert(options.title == "Testtitel" and options.maketitle and options.toc and options.lof and not options.lot)
absent(output, "fancy")
absent(output, "linkcolor")
absent(output, "Kernpunkte ()")
absent(output, "≥$>=$")
absent(output, "≤$<=$")
contains(output, "$>=$ 800")
contains(output, "$<=$ 15")
contains(output, "- Außen")
contains(output, "  - Innen")
absent(output, "- - ")
absent(output, "Abb. @")
absent(output, "Abschnitt @")
contains(output, "@fig-Eine-Abbildung")
contains(output, "#footnote[#cite(<zaloga2005MythGastricResidual>, supplement: [449])]")
contains(output, "#footnote[#cite(<zaloga2005MythGastricResidual>, supplement: [S. 450])]")
contains(output, "#image(\"bild.png\", width: 50%)")
contains(output, "#image(\"breit.png\", width: 100%)")
contains(output, "caption: [Eine Abbildung #cite(<zaloga2005MythGastricResidual>, supplement: [S. 449], style: \"chicago-author-date\")]")
contains(output, "#pagebreak()\n#columns(2)")
absent(output, "{{zaloga")

local without_title, absent_options = convert("\\begin{document}Text\\end{document}")
contains(without_title, "Text")
assert(not absent_options.maketitle and not absent_options.toc and not absent_options.lof)

local flowing = convert([[
\begin{document}
\begin{multicols}{2}Text\end{multicols}
\begin{multicols}{2}
\begin{figure}\includegraphics[width=\linewidth]{fluss.png}\caption{Bild}\end{figure}
\end{multicols}
\end{document}
]])
local _, column_count = flowing:gsub("#columns%(2%)", "")
assert(column_count == 1, "Benachbarte Spaltenblöcke wurden nicht zusammengeführt")
absent(flowing, "#pagebreak()")

local expanded = convert([[
\documentclass{article}
\newcommand{\gruess}[1]{Hallo #1}
\begin{document}\gruess{Welt}\end{document}
]])
contains(expanded, "Hallo Welt")
absent(expanded, "newcommand")

local bib = vim.fn.tempname() .. ".bib"
local file = assert(io.open(bib, "wb"))
file:write("@misc{RealKey, title = {Test}}\n")
file:close()
local resolved, warnings = process.resolve_bibliography("#cite(<realkey>)", bib)
assert(resolved == "#cite(<RealKey>)" and #warnings == 1)
os.remove(bib)
print("Tylax regression tests: OK")
