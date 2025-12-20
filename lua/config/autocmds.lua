-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})
--
-- vim.api.nvim_create_autocmd({ "FileType", "ModeChanged" }, {
--   callback = function()
--     if vim.bo.filetype == "snacks_picker_input" then
--       vim.opt.guicursor = "a:block"
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("BufLeave", {
--   pattern = "*",
--   callback = function()
--     if vim.bo.filetype == "snacks_picker_input" then
--       vim.opt.guicursor = "n-v-c:block,i:ver25,r-cr:hor20,o:hor50"
--     end
--   end,
-- })
