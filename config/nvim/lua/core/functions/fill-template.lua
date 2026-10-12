-- ~/.config/nvim/lua/core/functions/fill-template.lua
--
-- Allgemeiner Template-Filler für persistente Eingabefelder.
--
-- Funktioniert unabhängig von Dateityp und Projektstruktur.
--
-- Template ausfüllen:
--   <localleader>f
--   :TemplateFill
--
-- Unterstützte Marker:
--
--   {{INPUT}}
--       Normale Eingabestelle.
--
--   {{INPUT:NAME}}
--       Benannte Eingabestelle.
--
--   {{MIRROR:NAME}}
--       Übernimmt den Inhalt des zugehörigen {{INPUT:NAME}}.
--
-- Beispiel:
--
--   Titel: {{INPUT:TITLE}}
--   Kurzname: {{MIRROR:TITLE}}
--
-- Nicht ausgefüllte Marker bleiben persistent in der Datei und können
-- später erneut mit :TemplateFill bearbeitet werden.

local M = {}

-- ---------------------------------------------------------
-- Template ausfüllen
-- ---------------------------------------------------------

function M.fill()
  local ls = require("luasnip")

  local s = ls.snippet
  local i = ls.insert_node
  local f = ls.function_node
  local t = ls.text_node

  local bufnr = vim.api.nvim_get_current_buf()

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local content = table.concat(lines, "\n")

  -- -------------------------------------------------------
  -- Prüfen, ob offene Eingabefelder vorhanden sind
  -- -------------------------------------------------------

  if not content:find("{{INPUT", 1, true) then
    vim.notify("Keine offenen Template-Felder.", vim.log.levels.INFO)
    return
  end

  local nodes = {}
  local input_number = 1

  -- Name -> LuaSnip-Node-Nummer
  local named_inputs = {}

  local position = 1

  -- -------------------------------------------------------
  -- Template-Marker verarbeiten
  -- -------------------------------------------------------

  while true do
    local start_pos, end_pos, marker = content:find("({{[%u]+:?[^}]*}})", position)

    if not start_pos then
      local remaining = content:sub(position)

      if remaining ~= "" then
        table.insert(
          nodes,
          t(vim.split(remaining, "\n", {
            plain = true,
          }))
        )
      end

      break
    end

    -- -----------------------------------------------------
    -- Text vor dem Marker
    -- -----------------------------------------------------

    local before = content:sub(position, start_pos - 1)

    if before ~= "" then
      table.insert(
        nodes,
        t(vim.split(before, "\n", {
          plain = true,
        }))
      )
    end

    -- -----------------------------------------------------
    -- {{INPUT}}
    -- -----------------------------------------------------

    if marker == "{{INPUT}}" then
      table.insert(nodes, i(input_number, "{{INPUT}}"))

      input_number = input_number + 1
    else
      -- ---------------------------------------------------
      -- {{INPUT:NAME}}
      -- ---------------------------------------------------

      local input_name = marker:match("^{{INPUT:([^}]+)}}$")

      if input_name then
        local node_number = input_number

        named_inputs[input_name] = node_number

        table.insert(nodes, i(node_number, marker))

        input_number = input_number + 1
      else
        -- -------------------------------------------------
        -- {{MIRROR:NAME}}
        -- -------------------------------------------------

        local mirror_name = marker:match("^{{MIRROR:([^}]+)}}$")

        if mirror_name then
          local source_node = named_inputs[mirror_name]

          if source_node then
            table.insert(
              nodes,
              f(function(args)
                local value = args[1][1] or ""

                -- Solange das zugehörige Eingabefeld noch
                -- nicht ausgefüllt wurde, bleibt auch der
                -- Mirror als persistenter Marker erhalten.
                if value == "" or value:match("^{{INPUT:") then
                  return "{{MIRROR:" .. mirror_name .. "}}"
                end

                return value
              end, {
                source_node,
              })
            )
          else
            -- Der zugehörige INPUT befindet sich nicht vor
            -- diesem MIRROR oder ist nicht mehr als offener
            -- Marker vorhanden.
            table.insert(nodes, t(marker))
          end
        else
          -- Unbekannte {{...}}-Marker unverändert lassen
          table.insert(nodes, t(marker))
        end
      end
    end

    position = end_pos + 1
  end

  -- -------------------------------------------------------
  -- Finaler Exit-Node
  -- -------------------------------------------------------

  table.insert(nodes, i(0))

  -- -------------------------------------------------------
  -- Buffer durch LuaSnip-Snippet ersetzen
  -- -------------------------------------------------------

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })

  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  ls.snip_expand(s({
    trig = "",
    name = "Template-Felder",
  }, nodes))
end

-- ---------------------------------------------------------
-- Command
-- ---------------------------------------------------------

vim.api.nvim_create_user_command("TemplateFill", function()
  M.fill()
end, {
  desc = "Offene Template-Felder ausfüllen",
})

-- ---------------------------------------------------------
-- Globales Keymap
-- ---------------------------------------------------------

vim.keymap.set("n", "<localleader>f", function()
  M.fill()
end, {
  desc = "Template: Fill open fields",
})

return M
