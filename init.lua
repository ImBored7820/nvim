-- Bootstrap lazy.nvim before any other setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim", "ErrorMsg" },
      { "\nPress any key to exit...", "Normal" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load core configuration (options, keymaps, autocmds)
require("options")
require("keymaps")
require("autocmds")

-- Initialize lazy.nvim and load plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = {
    colorscheme = { "catppuccin-macchiato" },
  },
  checker = { enabled = true },
})
