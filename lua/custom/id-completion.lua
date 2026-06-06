-- ~/.config/nvim/lua/custom/id-completion.lua
local M = {}

function M.new()
  return setmetatable({}, { __index = M })
end

function M:get_completions(ctx, cb)
  -- Only trigger inside attribute values like aria-labelledby="..."
  local line = ctx.line
  local before_cursor = line:sub(1, ctx.cursor[2])

  if not before_cursor:match('[aria%-labelledby|aria%-describedby|aria%-controls|for]="[^"]*$') then
    cb({ items = {} })
    return
  end

  -- Scan buffer for id="..." values
  local ids = {}
  local seen = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for _, l in ipairs(lines) do
    for id in l:gmatch('id="([^"]+)"') do
      if not seen[id] then
        seen[id] = true
        table.insert(ids, {
          label = id,
          kind = vim.lsp.protocol.CompletionItemKind.Reference,
        })
      end
    end
  end

  cb({ items = ids })
end

return M
