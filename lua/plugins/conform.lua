-- formatter
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
        javascript = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        svelte = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        twig = { "djlint" },
      },
      formatters = {

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
              "--blank-line-after-tag",
              "extends",
              "--reformat",
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
