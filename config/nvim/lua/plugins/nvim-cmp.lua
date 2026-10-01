--
--
return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-cmdline",
    "petertriho/cmp-git",
    -- "micangl/cmp-vimtex", -- hatte 28.07. einen fehler im parser mit 104
    "hrsh7th/cmp-omni",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    local kind_icons = {
      article = "󰧮",
      book = "",
      incollection = "󱓷",
      Function = "󰊕",
      Constructor = "",
      Text = "󰦨",
      Method = "",
      Field = "󰅪",
      Variable = "󱃮",
      Class = "",
      Interface = "",
      Module = "",
      Property = "",
      Unit = "",
      Value = "󰚯",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "󰌁",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "󰀫",
      Struct = "",
      Event = "",
      Operator = "󰘧",
      TypeParameter = "",
    }

    -- 1) GLOBAL cmp.setup (ohne vimtex)
    local select_next = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "c" })

    local select_prev = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "c" })

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        --   ["<Tab>"] = cmp.mapping(function(fallback)
        --     if luasnip.jumpable(1) then
        --       luasnip.jump(1)
        --     else
        --       fallback()
        --     end
        --   end, { "i", "s" }),
        --
        -- Tab für "Enter" und weiter
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            })
          elseif luasnip.jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-Space>"] = cmp.mapping.complete(),

        -- ["<D-j>"] = select_next,
        -- ["\027[106;9u"] = select_next,
        --
        -- ["<D-k>"] = select_prev,
        -- ["\027[107;9u"] = select_prev,

        -- Disable the arrow-key defaults from cmp.mapping.preset.insert().
        -- This lets the cursor move normally even when the completion menu is open.
        -- ["<Down>"] = cmp.config.disable,
        -- ["<Up>"] = cmp.config.disable,

        ["<D-b>"] = cmp.mapping.scroll_docs(-4),
        ["<D-f>"] = cmp.mapping.scroll_docs(4),

        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
      }),

      -- formatting = {
      --   fields = { "kind", "abbr", "menu" },
      --   format = function(entry, vim_item)
      --     vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
      --     vim_item.menu = ({
      --       vimtex = vim_item.menu,
      --       luasnip = "[Snippet]",
      --       nvim_lsp = "[LSP]",
      --       buffer = "[Buffer]",
      --       spell = "[Spell]",
      --       cmdline = "[CMD]",
      --       path = "[Path]",
      --     })[entry.source.name]
      --     return vim_item
      --   end,
      -- },
      formatting = {
        fields = { "kind", "abbr", "menu" },

        format = function(entry, vim_item)
          if entry.source.name == "omni" then
            -- Alle Zotero-/VimTeX-Einträge bekommen dasselbe Icon
            vim_item.kind = "󰧮"
            vim_item.menu = "[Zotero]"
            return vim_item
          end

          vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind

          vim_item.menu = ({
            luasnip = "[Snippet]",
            nvim_lsp = "[LSP]",
            buffer = "[Buffer]",
            spell = "[Spell]",
            cmdline = "[CMD]",
            path = "[Path]",
            cmp_r = "[R]",
            git = "[Git]",
          })[entry.source.name] or ""

          return vim_item
        end,
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
        { name = "cmp_r" },
      }),

      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },

      view = { entries = "custom" },

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      performance = {
        trigger_debounce_time = 500,
        throttle = 550,
        fetching_timeout = 80,
      },
    })

    -- 2) FILETYPE override: nur hier vimtex dazu
    -- cmp.setup.filetype({ "tex", "plaintex", "bib", "rnw" }, {
    cmp.setup.filetype({ "tex", "plaintex", "rnw" }, {
      sources = cmp.config.sources({
        -- { name = "vimtex" },
        {
          name = "omni",
          option = {
            disable_omnifuncs = {
              "v:lua.vim.lsp.omnifunc",
            },
          },
        },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
        { name = "cmp_r" },
      }),
    })

    -- 3) cmdline setups
    local cmdline_mapping = cmp.mapping.preset.cmdline({
      ["<Down>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { "c" }),

      ["<Up>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "c" }),

      ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
          fallback()
        end
      end, { "c" }),
    })

    cmp.setup.cmdline("/", {
      mapping = cmdline_mapping,
      sources = cmp.config.sources({
        { name = "buffer", keyword_length = 3 },
      }),
      completion = { completeopt = "menu,menuone,noselect" },
    })

    cmp.setup.cmdline(":", {
      mapping = cmdline_mapping,
      sources = cmp.config.sources({
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "cmdline" },
      }),
      completion = { completeopt = "menu,menuone,noselect" },
    })
  end,
}
