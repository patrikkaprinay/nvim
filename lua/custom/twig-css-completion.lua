-- ~/.config/nvim/lua/custom/twig-css-completion.lua
local scanner = require("custom.twig-scanner")
local M = {}

function M.new()
  scanner.start()
  return setmetatable({}, { __index = M })
end

function M:get_completions(ctx, cb)
  local line = ctx.line
  local col = ctx.cursor[2]
  local before = line:sub(1, col)

  local items = {}

  -- After a dot: suggest classes
  if before:match("%.$") or before:match("%.([%w_-]*)$") then
    for class, files in pairs(scanner.classes) do
      local sources = table.concat(vim.tbl_keys(files), ", ")
      table.insert(items, {
        label = class,
        kind = vim.lsp.protocol.CompletionItemKind.Class,
        documentation = "Used in: " .. sources,
      })
    end
  end

  -- After a hash: suggest ids
  if before:match("#$") or before:match("#([%w_-]*)$") then
    for id, files in pairs(scanner.ids) do
      local sources = table.concat(vim.tbl_keys(files), ", ")
      table.insert(items, {
        label = id,
        kind = vim.lsp.protocol.CompletionItemKind.Reference,
        documentation = "Used in: " .. sources,
      })
    end
  end

  cb({ items = items })
end

return M
