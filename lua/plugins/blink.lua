return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      -- Define which sources are enabled
      default = { "lsp", "path", "snippets", "buffer" },

      providers = {
        buffer = {
          -- 1. Setup the buffer source to look at all loaded buffers
          -- This is crucial. By default, it often only looks at the current buffer.
          opts = {
            get_bufnrs = function()
              return vim.tbl_filter(function(bufnr)
                return vim.api.nvim_buf_is_loaded(bufnr)
              end, vim.api.nvim_list_bufs())
            end,
          },

          -- 2. Optimization: Only trigger this aggressive scanning when typing
          -- This keeps performance high.
          min_keyword_length = 3,
        },
      },
    },
    keymap = {
      preset = "super-tab",
      ["<Tab>"] = {
        require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
        require("lazyvim.util.cmp").map({ "snippet_forward", "ai_accept" }),
        "fallback",
      },
    },
  },
}
