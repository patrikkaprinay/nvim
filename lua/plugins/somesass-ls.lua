return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      -- Register default_config if not already defined
      if not lspconfig.somesass_ls then
        lspconfig.somesass_ls = {
          default_config = {
            name = "somesass_ls",
            cmd = { "some-sass-language-server", "--stdio" },
            filetypes = { "scss", "sass" },
            root_dir = function(fname)
              return util.root_pattern(".git", "package.json")(fname)
            end,
            settings = {
              somesass = {
                suggestAllFromOpenDocument = true,
              },
            },
          },
        }
      end

      -- Tell LazyVim to activate the server
      opts.servers = opts.servers or {}
      opts.servers.somesass_ls = {
        -- You can override user settings here if needed
        settings = {
          somesass = {
            suggestAllFromOpenDocument = true,
          },
        },
      }

      return opts
    end,
  },
}
