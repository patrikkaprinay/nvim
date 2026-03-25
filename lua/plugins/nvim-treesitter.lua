return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = {
      enable = true,
      disable = { "scss" },
    },
    ensure_installed = {
      "svelte",
      "twig",
      "php",
      "twig",
      "html",
      "css",
      "c",
    },
  },
}
