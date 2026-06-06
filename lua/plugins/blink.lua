return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = {
        auto_show = function(ctx)
          local line = ctx.line
          local col = ctx.cursor[2]
          local before = line:sub(1, col)
          local after = line:sub(col + 1)
          if before:match(">$") and after:match("^</") then
            return false
          end
          return true
        end,
      },
      ghost_text = {
        enabled = false,
      },
    },
    keymap = {
      ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer", "datastar", "html-ids", "twig-css" },
      providers = {
        snippets = {
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              -- LuaSnip snippets have a source you can check
              -- Boost only specific triggers you defined
              local boosted = { "s", "svg", "t", "tt" } -- your triggers
              if vim.tbl_contains(boosted, item.label) then
                item.score_offset = (item.score_offset or 0) + 100
              end
            end
            return items
          end,
        },
        ["html-ids"] = {
          name = "html-ids",
          module = "custom.id-completion",
          score_offset = 50,
        },
        ["twig-css"] = {
          name = "twig-css",
          module = "custom.twig-css-completion",
          enabled = function()
            return vim.bo.filetype == "scss" or vim.bo.filetype == "css"
          end,
          score_offset = 50,
        },
        datastar = {
          name = "datastar",
          module = "datastar.cmp_source",
          score_offset = 100,
        },
      },
    },
  },
}
