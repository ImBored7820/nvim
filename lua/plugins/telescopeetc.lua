-- Project switcher: change to different project folders
return {
  "nvim-telescope/telescope-project.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = "Telescope",
  keys = {
    { "<leader>fp", "<cmd>Telescope project<cr>", desc = "Switch project folder" },
  },
  config = function()
    require("telescope").load_extension("project")
  end,
}
