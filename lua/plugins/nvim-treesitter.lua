return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = {
      enable = true,
      disable = { "scss" },
    },
    ensure_installed = {
      "svelte",
      "twiggy_language_server",
      "php",
      "twig",
      "html",
    },
  },
}
