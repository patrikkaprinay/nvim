return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "datastar", "snippets", "lsp", "path", "buffer" },
      providers = {
        datastar = {
          name = "datastar",
          module = "datastar.cmp_source",
          score_offset = 100, -- prioritize Datastar completions
        },
        -- snippets = {
        --   score_offset = 5,
        --   transform_items = function(_, items)
        --     local trigger_prefixes = { "s" }
        --     for _, item in ipairs(items) do
        --       local label = item.label or ""
        --       for _, prefix in ipairs(trigger_prefixes) do
        --         if label:match("^" .. prefix) then
        --           item.score_offset = (item.score_offset or 0) + 15
        --           break
        --         end
        --       end
        --     end
        --     return items
        --   end,
        -- },
      },
    },

    fuzzy = {
      use_frecency = true, -- Enable frecency-based sorting
      use_proximity = true, -- Boost items closer to cursor
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
