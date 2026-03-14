-- File browser: browse and switch directories
return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>fd", "<cmd>Telescope file_browser path=%:p:h<cr>", desc = "File browser (current dir)" },
    { "<leader>fD", "<cmd>Telescope file_browser<cr>", desc = "File browser (cwd)" },
  },
  config = function()
    require("telescope").load_extension("file_browser")
  end,
}

