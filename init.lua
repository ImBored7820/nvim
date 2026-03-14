if vim.g.neovide then
    vim.g.neovide_title_background_color = "#24273a" -- Macchiato Base
    vim.g.neovide_title_text_color = "#cad3f5"       -- Macchiato Text
    
    vim.g.neovide_floating_shadow = true
    vim.g.neovide_floating_z_height = 10
    vim.g.neovide_light_radius = 5
    vim.g.neovide_window_blurred = true

end


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

