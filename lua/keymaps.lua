-- Keymaps and formatting functions for the notes application
-- Spell check (built-in, when spell enabled): [s prev error, ]s next error, z= correct word

local function wrap_selection(open, close)
  -- Visual mode: wrap selected text with open/close markers
  -- Uses vim's gv and visual-mode replace to avoid complex index math
  local start_mark = vim.api.nvim_buf_get_mark(0, "<")
  local end_mark = vim.api.nvim_buf_get_mark(0, ">")
  local start_row, start_col = start_mark[1], start_mark[2]
  local end_row, end_col = end_mark[1], end_mark[2]

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  if #lines == 0 then return end

  local selected
  if #lines == 1 then
    selected = lines[1]:sub(start_col + 1, end_col + 1)
  else
    local parts = { lines[1]:sub(start_col + 1) }
    for i = 2, #lines - 1 do
      parts[#parts + 1] = lines[i]
    end
    parts[#parts + 1] = lines[#lines]:sub(1, end_col + 1)
    selected = table.concat(parts, "\n")
  end

  local stripped = selected:gsub("^%s+", ""):gsub("%s+$", "")
  if stripped:match("^" .. vim.pesc(open)) and stripped:match(vim.pesc(close) .. "$") then
    return
  end

  local wrapped = open .. stripped .. close

  if #lines == 1 then
    local line = lines[1]
    local new_line = line:sub(1, start_col) .. wrapped .. line:sub(end_col + 2)
    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, { new_line })
  else
    local result = {}
    result[1] = lines[1]:sub(1, start_col) .. open .. lines[1]:sub(start_col + 1)
    for i = 2, #lines - 1 do
      result[i] = lines[i]
    end
    result[#lines] = lines[#lines]:sub(1, end_col + 1) .. close .. lines[#lines]:sub(end_col + 2)
    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, result)
  end

  vim.cmd("normal! gv")
end

local function wrap_word(open, close)
  -- Normal mode: wrap word under cursor
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if not line then return end

  local col_1 = col + 1
  local before = line:sub(1, col_1 - 1)
  local after = line:sub(col_1)

  local word_start = before:match("()[%w_]*$")
  local word_end = after:match("^[%w_]*()")
  if not word_start or not word_end then return end

  local ws = word_start - 1
  local we = col_1 + word_end - 2
  local word = line:sub(ws + 1, we + 1)
  if #word == 0 then return end

  local stripped = word:gsub("^%s+", ""):gsub("%s+$", "")
  if stripped:match("^" .. vim.pesc(open)) and stripped:match(vim.pesc(close) .. "$") then
    return
  end

  local new_line = line:sub(1, ws) .. open .. stripped .. close .. line:sub(we + 2)
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  vim.api.nvim_win_set_cursor(0, { row, ws + #open + #stripped - 1 })
end

local function format_bold()
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    wrap_selection("**", "**")
  else
    wrap_word("**", "**")
  end
end

local function format_italic()
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    wrap_selection("*", "*")
  else
    wrap_word("*", "*")
  end
end

local function format_underline()
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    wrap_selection("<u>", "</u>")
  else
    wrap_word("<u>", "</u>")
  end
end

-- Formatting keybinds: visual mode (b,i,u), normal mode (<leader>fb/fi/fu)
-- Note: 'i' is insert mode, 'gi' goes to last insert - use leader prefix for normal
vim.keymap.set("n", "<leader>fb", format_bold, { desc = "Format word bold (**text**)" })
vim.keymap.set("n", "<leader>fi", format_italic, { desc = "Format word italic (*text*)" })
vim.keymap.set("n", "<leader>fu", format_underline, { desc = "Format word underline (<u>text</u>)" })
vim.keymap.set("v", "b", format_bold, { desc = "Format selection bold" })
vim.keymap.set("v", "i", format_italic, { desc = "Format selection italic" })
vim.keymap.set("v", "u", format_underline, { desc = "Format selection underline" })
vim.keymap.set("i", "<C-b>", format_bold, { desc = "Format bold" })
vim.keymap.set("i", "<C-i>", format_italic, { desc = "Format italic" })
vim.keymap.set("i", "<C-u>", format_underline, { desc = "Format underline" })
