return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      width = 0.9,
    },
    plugins = {
      options = {
        enabled = false, -- THIS is key (don’t touch UI)
      },
      twilight = { enabled = false },
      gitsigns = { enabled = false },
      tmux = { enabled = false },
    },
  },
}
