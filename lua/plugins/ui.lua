-- UI plugins: colorscheme, bufferline, statusline, file explorer

return {
  -- Catppuccin Macchiato colorscheme (priority 1000, lazy=false for early load)
  {
    "catppuccin/nvim",
    name = "catppuccin-macchiato",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "macchiato",
      integrations = {
        bufferline = true,
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = { enabled = true },
        indent_blankline = { enabled = true },
        mini = { enabled = false },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },

  -- Buffer tabs across the top, styled for Catppuccin (highlights after catppuccin loads)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    event = "BufAdd",
    opts = {
      options = {
        mode = "tabs",
        diagnostics = "none",
        always_show_bufferline = true,
        separator_style = "slant",
        offsets = {
          { filetype = "NvimTree", text = "Files", highlight = "Directory" },
        },
      },
    },
    config = function(_, opts)
      local ok, hl = pcall(require, "catppuccin.groups.integrations.bufferline")
      opts.highlights = ok and hl.get() or {}
      require("bufferline").setup(opts)
    end,
  },

  -- Minimal statusline: filename, word count, spell, filetype (depends on catppuccin for theme)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    event = "VeryLazy",
    opts = function()
      local function word_count()
        if vim.bo.ft == "markdown" or vim.bo.ft == "text" then
          local words = vim.fn.wordcount().words
          return words and (words .. " words") or ""
        end
        return ""
      end

      local function spell_status()
        return vim.wo.spell and "SPELL" or ""
      end

      return {
        options = {
          theme = "catppuccin",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "filename" },
          lualine_c = { { word_count, color = { fg = "#a6e3a1" } } },
          lualine_x = { { spell_status, color = { fg = "#f9e2af" } }, "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = { "filename" },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },

  -- File explorer sidebar, toggled with keybind
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      {
        "<leader>e",
        "<cmd>NvimTreeToggle<cr>",
        desc = "Toggle file explorer",
      },
    },
    opts = {
      view = { width = 35 },
      renderer = {
        group_empty = true,
        icons = { show = { file = true, folder = true } },
      },
      filters = { dotfiles = false },
      git = { enable = true },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
    end,
  },
}
