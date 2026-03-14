-- Autocommands for the notes application

local augroup = vim.api.nvim_create_augroup("NotesApp", { clear = true })

-- Enable spell check for markdown and text files (spell is window-local, use vim.wo/vim.cmd)
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.cmd("setlocal spell spelllang=en_us")
  end,
  desc = "Enable spell check for note filetypes",
})

-- Set filetype for common note extensions
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = { "*.md", "*.mdx", "*.txt", "*.note" },
  callback = function()
    if vim.bo.filetype == "" then
      local ext = vim.fn.expand("%:e")
      if ext == "md" or ext == "mdx" then
        vim.bo.filetype = "markdown"
      elseif ext == "txt" or ext == "note" then
        vim.bo.filetype = "text"
      end
    end
  end,
  desc = "Set filetype for note extensions",
})
