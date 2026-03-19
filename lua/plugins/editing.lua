--[[
  Editing plugins: completion, autopairs, indent guides, bullet lists

  BULLET HIERARCHY (bullets.vim outline_levels):
  --------------------------------------------
  The levels I. → A. → i. → a. → 1. are OUTLINE levels for Tab/Shift-Tab:

    I.        ← Level 1 (press Tab to demote → A.)
      A.      ← Level 2 (press Tab to demote → i.)
        i.    ← Level 3 (press Tab to demote → a.)
          a.  ← Level 4 (press Tab to demote → 1.)
            1. ← Level 5 (bottom level)

  - Enter on "I. text" creates "II." (continues the same level)
  - Tab on "I." demotes to "  A." (one level deeper)
  - Shift-Tab promotes (one level shallower)

  NOTE: To switch bullet types (e.g. from Roman to numeric), insert a blank
  line between lists. bullets.vim detects list type from the previous bullet line.
]]

return {
  -- Completion engine (buffer, path, snippets only — no LSP)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete({ desc = "Trigger completion" }),
          -- Fall through to bullets.vim when completion menu is closed
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ select = false })
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-e>"] = cmp.mapping.abort({ desc = "Close completion" }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4, { desc = "Scroll docs up" }),
          ["<C-f>"] = cmp.mapping.scroll_docs(4, { desc = "Scroll docs down" }),
        }),
        sources = cmp.config.sources(
          { { name = "path" }, { name = "luasnip" } },
          { { name = "buffer", option = { keyword_length = 2 } } }
        ),
      })
    end,
  },

  -- LuaSnip snippet engine
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    config = function(_, opts)
      require("luasnip").setup(opts)
    end,
  },

  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = "hrsh7th/nvim-cmp",
    opts = {
      check_ts = true,
      ts_config = { map_cr = true },
    },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Indent guides matching Catppuccin (v3 API: main = "ibl")
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "▏", tab_char = "▏" },
      scope = { enabled = false },
      exclude = { filetypes = { "help", "NvimTree", "lazy" } },
    },
  },

  -- Smart bullets: hierarchy I. A. i. a. 1. (use C-t/C-d or >>/<< for demote/promote)
  -- ft trigger loads only for .md, .txt, gitcommit (autocmds set filetype for *.txt)
  {
    "dkarter/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    init = function()
      vim.g.bullets_outline_levels = { "ROM", "ABC", "rom", "abc", "num" }
      vim.g.bullets_set_mappings = 1
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
      vim.g.bullets_delete_last_bullet_if_empty = 1
      vim.g.bullets_pad_right = 1
      vim.g.bullets_line_spacing = 1
      vim.g.bullets_renumber_on_change = 1
    end,
  },
}
