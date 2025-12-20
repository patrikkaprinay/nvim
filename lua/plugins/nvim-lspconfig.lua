return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        twiggy_language_server = {
          enabled = true,
        },
        html = {
          filetypes = { "html", "twig" },
        },
        emmet_language_server = {
          filetypes = {
            "html",
            "css",
            "javascript",
            "javascriptreact",
            "typescriptreact",
            "twig",
          },
        },

        -- cssls = {
        --   filetypes = {
        --     "scss",
        --   },
        --   settings = {
        --     css = {
        --       validate = true,
        --     },
        --     scss = {
        --       validate = true,
        --     },
        --     less = {
        --       validate = true,
        --     },
        --   },
        -- },
      },
    },
  },
}
