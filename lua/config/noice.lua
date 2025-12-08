require("noice").setup({
  routes = {
    {
      filter = { event = "msg_show" },
      opts = { timeout = 5000 },
    },
  },
})
