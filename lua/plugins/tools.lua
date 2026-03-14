-- Tool plugins: telescope, zen-mode, gitsigns, comment, markdown-preview

return {
  -- Fuzzy finder for notes: find files and grep content
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find note files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep note contents" },
    },
    opts = {
      defaults = {
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
    end,
  },

  -- Distraction-free writing mode
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
    },
    opts = {
      window = {
        width = 0.85,
        options = { number = true, relativenumber = true },
      },
      plugins = {
        gitsigns = { enabled = true },
        tmux = { enabled = false },
      },
    },
    config = function(_, opts)
      require("zen-mode").setup(opts)
    end,
  },

  -- Git diff indicators in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      current_line_blame = false,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
  },

  -- Toggle line comments with gcc
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", desc = "Toggle line comment" },
      { "gbc", desc = "Toggle block comment" },
      { "gc", mode = "n", desc = "Comment operator" },
      { "gb", mode = "n", desc = "Block comment operator" },
    },
    opts = {
      toggler = { line = "gcc", block = "gbc" },
      opleader = { line = "gc", block = "gb" },
    },
    config = function(_, opts)
      require("Comment").setup(opts)
    end,
  },

  -- Live markdown preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle markdown preview" },
    },
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
}
