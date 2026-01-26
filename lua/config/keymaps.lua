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
