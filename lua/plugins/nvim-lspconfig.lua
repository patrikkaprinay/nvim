return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
              },
              format = {
                enable = false,
              },
              environment = {
                includePaths = {
                  "vendor/craftcms/cms/src",
                },
              },
            },
          },
        },
        phpactor = { enabled = false },
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
