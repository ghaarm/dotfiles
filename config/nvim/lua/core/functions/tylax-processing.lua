-- Kleine Korrekturen um den strukturbasierten Tylax-Konverter herum.
-- Verschachtelte TeX-Argumente werden als Gruppen gelesen; Listen, Formeln,
-- Abbildungen und Spalten bleiben Aufgabe des Tylax-Parsers.
local M = {}

local function group(source, pos, opener, closer)
  if source:sub(pos, pos) ~= opener then return nil, pos end
  local depth, start = 0, pos + 1
  for i = pos, #source do
    local char = source:sub(i, i)
    if char == opener and source:sub(i - 1, i - 1) ~= "\\" then
      depth = depth + 1
    elseif char == closer and source:sub(i - 1, i - 1) ~= "\\" then
      depth = depth - 1
      if depth == 0 then return source:sub(start, i - 1), i + 1 end
    end
  end
  return nil, pos
end

local function argument(source, pos, opener, closer)
  pos = source:find("%S", pos) or (#source + 1)
  return group(source, pos, opener, closer)
end

local function identity(label)
  return label:lower():gsub("[%s%p]", "")
end

local function clean_label(label)
  return label:gsub("[,%s]+", "-"):gsub("%-+", "-"):gsub("%-+$", "")
end

local function find_title(preamble)
  local pos = preamble:find("\\title%s*%{")
  if not pos then return nil end
  local brace = preamble:find("{", pos, true)
  local title = group(preamble, brace, "{", "}")
  if title and not title:find("\\", 1, true) then return title:match("^%s*(.-)%s*$") end
end

local function macro_definitions(preamble)
  local definitions, pos = {}, 1
  while pos <= #preamble do
    local char = preamble:sub(pos, pos)
    if char == "%" and preamble:sub(pos - 1, pos - 1) ~= "\\" then
      pos = (preamble:find("\n", pos, true) or #preamble) + 1
    elseif char ~= "\\" then
      pos = pos + 1
    else
      local command = preamble:match("^\\([%a@]+)", pos)
      if command ~= "newcommand" and command ~= "renewcommand" and command ~= "providecommand"
        and command ~= "DeclareMathOperator" then
        pos = pos + (command and #command + 1 or 2)
      else
        local after = pos + #command + 1
        if preamble:sub(after, after) == "*" then after = after + 1 end
        local name, ending = argument(preamble, after, "{", "}")
        if name then
          local optional, next_pos = argument(preamble, ending, "[", "]")
          if optional then ending = next_pos end
          optional, next_pos = argument(preamble, ending, "[", "]")
          if optional then ending = next_pos end
          local definition, final = argument(preamble, ending, "{", "}")
          if definition then
            definitions[#definitions + 1] = preamble:sub(pos, final - 1)
            pos = final
          else
            pos = after
          end
        else
          pos = after
        end
      end
    end
  end
  return table.concat(definitions, "\n")
end

function M.prepare(source)
  local start = source:find("\\begin%s*%{document%}")
  if not start then return nil, "\\begin{document} fehlt" end
  local finish = source:find("\\end%s*%{document%}", start)
  if not finish then return nil, "\\end{document} fehlt" end
  local preamble = source:sub(1, start - 1)
  local body = source:sub(source:find("}", start, true) + 1, finish - 1)
  local options = { title = find_title(preamble), toc = false, lof = false, lot = false,
    maketitle = false, warnings = {} }

  local labels = {}
  for label in body:gmatch("\\label%s*%{([^{}]+)%}") do
    local key = identity(label)
    if labels[key] == nil then labels[key] = label
    elseif labels[key] ~= label then labels[key] = false end
  end

  local result, pos = {}, 1
  while pos <= #body do
    local char = body:sub(pos, pos)
    if char == "%" and body:sub(pos - 1, pos - 1) ~= "\\" then
      local next_line = body:find("\n", pos, true) or (#body + 1)
      result[#result + 1] = body:sub(pos, next_line)
      pos = next_line + 1
    elseif char ~= "\\" then
      result[#result + 1] = char
      pos = pos + 1
    else
      local command = body:match("^\\([%a@]+)", pos)
      if not command then
        result[#result + 1] = body:sub(pos, pos + 1)
        pos = pos + 2
      else
        local after = pos + #command + 1
        local replacement, next_pos
        if command == "ignore" then
          local _, ending = argument(body, after, "{", "}")
          if ending ~= after then replacement, next_pos = "", ending end
        elseif command == "item" then
          local marker, ending = argument(body, after, "[", "]")
          if marker and marker:match("^%s*%-%s*$") then replacement, next_pos = "\\item", ending end
        elseif command == "includegraphics" then
          local size, ending = argument(body, after, "[", "]")
          if size then
            local fixed = size:gsub("width%s*=%s*\\linewidth", "width=1\\linewidth")
              :gsub("width%s*=%s*\\textwidth", "width=1\\textwidth")
            if fixed ~= size then
              replacement = "\\includegraphics[" .. fixed .. "]"
              next_pos = ending
            end
          end
        elseif command == "footcite" then
          local page, ending = argument(body, after, "[", "]")
          local key, final = argument(body, page and ending or after, "{", "}")
          if key then
            replacement = "\\footnote{\\cite" .. (page and ("[" .. page .. "]") or "") .. "{" .. key .. "}}"
            next_pos = final
          end
        elseif command == "ref" or command == "autoref" then
          local label, ending = argument(body, after, "{", "}")
          if label then
            replacement = "\\ref{" .. (labels[identity(label)] or label) .. "}"
            next_pos = ending
          end
        elseif command == "hypersetup" or command == "thispagestyle" or command == "pagestyle" then
          local _, ending = argument(body, after, "{", "}")
          if ending ~= after then
            replacement, next_pos = "", ending
            if command == "hypersetup" then
              options.warnings[#options.warnings + 1] = "\\hypersetup: Farben werden von der Typst-Vorlage bestimmt"
            end
          end
        elseif command == "hypertarget" then
          local _, ending = argument(body, after, "{", "}")
          local _, final = argument(body, ending, "{", "}")
          if final ~= ending then replacement, next_pos = "", final end
        elseif command == "maketitle" then
          options.maketitle = true
          replacement, next_pos = "", after
        elseif command == "tableofcontents" or command == "listoffigures" or command == "listoftables"
          or command == "printbibliography" then
          local flag = ({ tableofcontents = "toc", listoffigures = "lof", listoftables = "lot" })[command]
          if flag then options[flag] = true end
          replacement, next_pos = "", after
        end
        result[#result + 1] = replacement or body:sub(pos, after - 1)
        pos = next_pos or after
      end
    end
  end
  return macro_definitions(preamble) .. "\n\\begin{document}\n" .. table.concat(result)
    .. "\n\\end{document}\n", options
end

local function cite_in_caption(caption)
  caption = caption:gsub("%{%{([%w_:%-]+)%},%s*([^{}]+)%}", function(key, page)
    return ' #cite(<' .. key .. '>, supplement: [' .. page .. '], style: "chicago-author-date")'
  end)
  caption = caption:gsub("%{([%w_:%-]+)%}", function(key)
    return ' #cite(<' .. key .. '>, style: "chicago-author-date")'
  end)
  return caption
end

function M.postprocess(content)
  local counts = { labels = 0, lengths = 0, captions = 0 }
  content = content:gsub("<([^<>\r\n]+)>", function(label)
    if not label:find("[,%s]") then return "<" .. label .. ">" end
    local fixed = clean_label(label)
    if fixed ~= label then counts.labels = counts.labels + 1 end
    return "<" .. fixed .. ">"
  end)
  content = content:gsub("#v%(%s*(%d+%.?%d*)%s+(%a+)%s*%)", function(value, unit)
    if ({ mm = true, cm = true, pt = true, em = true, ["in"] = true })[unit] then
      counts.lengths = counts.lengths + 1
      return "#v(" .. value .. unit .. ")"
    end
    return "#v(" .. value .. " " .. unit .. ")"
  end)
  content = content:gsub("(caption:%s*%[)(.-)(%],)", function(a, caption, z)
    local fixed = cite_in_caption(caption)
    if fixed ~= caption then counts.captions = counts.captions + 1 end
    return a .. fixed .. z
  end)
  content = content:gsub("#footnote%[#cite%(<([^<>]+)>%),%s*([^%]]+)%]", function(key, page)
    return "#footnote[#cite(<" .. key .. ">, supplement: [" .. page .. "])]"
  end)
  content = content:gsub("(\n[ \t]*=+[^\n]-)%s+%(%)([ \t]*\n)", "%1%2")
  content = content:gsub("^([ \t]*=+[^\n]-)%s+%(%)([ \t]*\n)", "%1%2")
  content = content:gsub("Abb%.%s+(@fig[%w_%-%.]+)", "%1")
  content = content:gsub("Abbildung%s+(@fig[%w_%-%.]+)", "%1")
  content = content:gsub("Abschnitt%s+(@sec[%w_%-%.]+)", "%1")
  content = content:gsub("Abschnitt%s+(@sub[%w_%-%.]+)", "%1")
  content = content:gsub("Abb%.%s+(#ref%(<fig[^>]+>%))", "%1")
  content = content:gsub("Abbildung%s+(#ref%(<fig[^>]+>%))", "%1")
  content = content:gsub("Abschnitt%s+(#ref%(<s[eu][bc][^>]+>%))", "%1")
  -- Direkt aufeinanderfolgende multicols-Umgebungen gleicher Breite bilden
  -- einen einzigen Fluss. Getrennte Typst-Spaltenblöcke können Fußnoten
  -- gegen den Inhalt des nächsten Blocks laufen lassen.
  local did_merge
  repeat
    did_merge = false
    content = content:gsub("#columns%((%d+)%)%s*(%b[])(%s*)#columns%((%d+)%)%s*(%b[])",
      function(first_count, first, gap, second_count, second)
        if first_count ~= second_count then
          return "#columns(" .. first_count .. ")" .. first .. gap .. "#columns(" .. second_count .. ")" .. second
        end
        did_merge = true
        return "#columns(" .. first_count .. ")[" .. first:sub(2, -2) .. "\n"
          .. second:sub(2, -2) .. "]"
      end)
  until not did_merge
  content = content:gsub("#columns%((%d+)%)%s*(%b[])", function(columns, block)
    local rest, figures = block:sub(2, -2):gsub("#figure%b()", "")
    rest = rest:gsub("<[^<>]+>", "")
    if tonumber(columns) > 1 and figures > 0 and rest:match("^%s*$") then
      return "#pagebreak()\n#columns(" .. columns .. ")" .. block
    end
    return "#columns(" .. columns .. ")" .. block
  end)
  return content, counts
end

function M.resolve_bibliography(content, path)
  local warnings = {}
  if not path then return content, { "Keine Bibliografiedatei in der Vorlage gefunden" } end
  local file = io.open(path, "rb")
  if not file then return content, { "Bibliografiedatei nicht lesbar: " .. path } end
  local bibliography = file:read("*a")
  file:close()
  local exact, folded = {}, {}
  for key in bibliography:gmatch("@[%a]+%s*%{%s*([^,%s]+)%s*,") do
    exact[key] = true
    local lower = key:lower()
    if folded[lower] == nil then folded[lower] = key else folded[lower] = false end
  end
  local seen = {}
  content = content:gsub("#cite%(<([^<>]+)>", function(key)
    if exact[key] then return "#cite(<" .. key .. ">" end
    local replacement = folded[key:lower()]
    if replacement then
      if not seen[key] then
        warnings[#warnings + 1] = "Zitierschlüssel-Großschreibung korrigiert: " .. key .. " → " .. replacement
        seen[key] = true
      end
      return "#cite(<" .. replacement .. ">"
    end
    if not seen[key] then
      warnings[#warnings + 1] = "Zitierschlüssel fehlt in der Bibliografie: " .. key
      seen[key] = true
    end
    return "#cite(<" .. key .. ">"
  end)
  return content, warnings
end

return M
