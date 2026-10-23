local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Überschrift in einen gültigen Label-Namen umwandeln.
local function slugify(text)
  local replacements = {
    ["Ä"] = "Ae",
    ["Ö"] = "Oe",
    ["Ü"] = "Ue",
    ["ä"] = "ae",
    ["ö"] = "oe",
    ["ü"] = "ue",
    ["ß"] = "ss",
    ["ẞ"] = "SS",
  }

  for from, to in pairs(replacements) do
    text = text:gsub(from, to)
  end

  text = text:lower()

  -- Sonderzeichen entfernen, Leerzeichen durch Bindestriche ersetzen.
  text = text:gsub("[^%w%s%-]", "")
  text = text:gsub("%s+", "-")
  text = text:gsub("%-+", "-")
  text = text:gsub("^%-", ""):gsub("%-$", "")

  return text
end

-- Label dynamisch aus dem eingegebenen Titel erzeugen.
local function make_label(prefix)
  return function(args)
    local title = args[1][1] or ""
    return "<" .. prefix .. ":" .. slugify(title) .. ">"
  end
end

-- Snippet für eine Überschriftenebene erzeugen.
local function heading_snippet(trigger, level)
  return s(trigger, {
    t(string.rep("=", level) .. " "),
    i(1, "Titel"),
    t(" "),
    f(make_label(trigger), { 1 }),
    i(0),
  })
end

return {
  heading_snippet("sec", 1),
  heading_snippet("sub", 2),
  heading_snippet("ssub", 3),
  heading_snippet("sssub", 4),
}
