-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local opts = { noremap = true, silent = true }

vim.keymap.set("i", "jk", "<Esc>", opts)
vim.keymap.set("n", "s", "vc")
vim.keymap.set("v", "s", "c")
-- replacing doesn't yank replaced text
vim.keymap.set("x", "p", '"_dP')
vim.keymap.set("v", "p", '"_dP')
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- vim.keymap.set("n", "<leader><space>", function()
--   require("fzf-lua").files()
-- end, { desc = "Find Files (fzf-lua, show dotfiles)" })

vim.keymap.set("n", "<leader>ft", ":NewTwig<CR>", { desc = "New Twig-SCSS file pair" })

vim.keymap.set("n", "<leader>cc", function()
  local file = vim.fn.expand("%")
  local output = vim.fn.expand("%:r") .. ".out"
  Snacks.terminal(
    string.format(
      "gcc -Wall -Wextra -g %s -o %s && ./%s; echo ''; echo 'Press Enter to close...'; read",
      file,
      output,
      output
    )
  )
end, { desc = "Compile and Run C Program" })

-- -- Compile C code
-- vim.keymap.set("n", "<leader>cc", function()
--   Snacks.terminal({ "gcc", "-g", "-Wall", "-o", "main.out", vim.fn.expand("%") })
-- end, { desc = "Compile C File" })
--
-- -- Run main.out
-- vim.keymap.set("n", "<leader>cx", function()
--   Snacks.terminal("./main.out; echo ''; read -p 'Press Enter to close...'")
-- end, { desc = "Run Program" })

-- -- Run compiled program
-- vim.keymap.set("n", "<leader>cx", function()
--   Snacks.terminal({ "./main.out" })
-- end, { desc = "Run Compiled Program" })

-- Go to buffer with space + [number] (bufferline.nvim)
local function goto_visible_buffer(n)
  local buffers = vim.t.bufs or vim.fn.getbufinfo({ buflisted = 1 })

  -- fallback if vim.t.bufs doesn't exist
  if not vim.t.bufs then
    buffers = vim.tbl_map(function(b)
      return b.bufnr
    end, buffers)
  end

  if buffers[n] then
    vim.cmd("buffer " .. buffers[n])
  end
end

for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function()
    goto_visible_buffer(i)
  end)
end

-- vim.keymap.set("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>")
-- vim.keymap.set("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>")
-- vim.keymap.set("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>")
-- vim.keymap.set("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>")
-- vim.keymap.set("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>")
-- vim.keymap.set("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>")
-- vim.keymap.set("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>")
-- vim.keymap.set("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>")
-- vim.keymap.set("n", "<leader>1", function()
--   vim.cmd("buffer 0")
-- end)
-- vim.keymap.set("n", "<leader>2", function()
--   vim.cmd("buffer 1")
-- end)
-- vim.keymap.set("n", "<leader>3", function()
--   vim.cmd("buffer 2")
-- end)
-- vim.keymap.set("n", "<leader>4", function()
--   vim.cmd("buffer 3")
-- end)
-- vim.keymap.set("n", "<leader>5", function()
--   vim.cmd("buffer 4")
-- end)
-- vim.keymap.set("n", "<leader>6", function()
--   vim.cmd("buffer 5")
-- end)
-- vim.keymap.set("n", "<leader>7", function()
--   vim.cmd("buffer 6")
-- end)
-- vim.keymap.set("n", "<leader>8", function()
--   vim.cmd("buffer 7")
-- end)
