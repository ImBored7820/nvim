-- Core Neovim options for the notes application
-- Optimized for note-taking: clean UI, readable text, markdown-friendly

local opt = vim.opt

-- Clipboard: use system clipboard for easy copy/paste
opt.clipboard = "unnamedplus"

-- Line wrapping: wrap long lines without breaking words
opt.wrap = true
opt.linebreak = true
opt.textwidth = 80

-- Tabs and indentation: 2-space soft tabs throughout
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line numbers: relative for navigation, absolute for current line
opt.number = true
opt.relativenumber = true

-- Cursor and scroll: keep context visible
opt.cursorline = true
opt.scrolloff = 4
opt.sidescrolloff = 4

-- Search: case-insensitive unless uppercase in query
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Split behavior: new splits open below/right
opt.splitbelow = true
opt.splitright = true

-- File handling
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- UI: hide clutter for a minimal notes experience
opt.showmode = false       -- Mode shown in statusline
opt.showcmd = false        -- Command in statusline
opt.ruler = false          -- Redundant with lualine
opt.cmdheight = 1
opt.laststatus = 2         -- Always show statusline
opt.showtabline = 2        -- Always show tabline (bufferline)
opt.signcolumn = "yes"     -- Keep sign column for gitsigns
opt.termguicolors = true

-- Completion and popups
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10

-- Conceal: hide markdown syntax in favor of formatting (optional)
opt.conceallevel = 0
