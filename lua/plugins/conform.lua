-- formatter
return {
  {
    "stevearc/conform.nvim",
    opts = {
      keep_backup = false,
      formatters_by_ft = {
        dotenv = {},
        sh = {},
        html = { "prettier" },
        javascript = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        svelte = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        twig = { "djlint" },
        php = {},
        c = { "clang-format" },
      },
      formatters = {
        prettier = {
          prepend_args = { "--tab-width", "4", "--no-use-tabs" },
        },
        twig_cs_fixer = {
          command = "twig-cs-fixer",
          args = { "lint", "--fix", "." },
          -- IMPORTANT: do *not* use stdin
          stdin = false,
        },
        djlint = {
          command = "djlint",
          args = function()
            -- reformat from stdin
            return {
              "--reformat",
              "--blank-line-after-tag",
              "extends,include",
              "--blank-line-before-tag",
              "include",
              "--profile",
              "nunjucks",
              "-",
            }
          end,
          stdin = true, -- important!
        },
      },
    },
  },
}
