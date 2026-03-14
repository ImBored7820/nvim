-- Treesitter for Markdown syntax highlighting (uses post-modular API: nvim-treesitter.setup)

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "markdown", "markdown_inline", "lua", "vim", "vimdoc" },
      highlight = { enable = true },
      indent = { enable = false },
    },
  },
}
