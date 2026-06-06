return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          cmd = { "xcrun", "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_markers = {
            "buildServer.json",
            "Package.swift",
            "*.xcodeproj",
            "*.xcworkspace",
            "compile_commands.json",
            ".sourcekit-lsp",
            ".git",
          },
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
            textDocument = {
              diagnostic = {
                dynamicRegistration = true,
                relatedDocumentSupport = true,
              },
            },
          },
        },
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
          settings = {
            twiggy = {
              diagnostics = {
                twigCsFixer = true,
              },
              framework = "craft",
            },
          },
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
          init_options = {
            showAbbreviationSuggestions = false,
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
