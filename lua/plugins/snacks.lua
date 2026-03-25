return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      cursor = "block",
      sources = {
        files = {
          exclude = {
            "vendor/*",
            ".idea/*",
            ".ddev/*",
            "storage/*",
            "web/cpresources/*",
            "web/uploads/*",
            "config/project/*",
          },
          hidden = true,
          ignored = true,
        },
        grep = {
          exclude = {
            "vendor/*",
            ".idea/*",
            ".ddev/*",
            "storage/*",
            "web/cpresources/*",
            "web/uploads/*",
            "config/project/*",
          },
          hidden = true,
          ignored = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
          layout = {
            layout = {
              width = 25,
            },
          },
        },
      },
    },
    dashboard = {
      preset = {
        keys = {
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        header = [[
  .__   __. ____    ____  __  .___  ___. 
  |  \ |  | \   \  /   / |  | |   \/   | 
  |   \|  |  \   \/   /  |  | |  \  /  | 
  |  . `  |   \      /   |  | |  |\/|  | 
  |  |\   |    \    /    |  | |  |  |  | 
  |__| \__|     \__/     |__| |__|  |__| ]],
        --         header = [[
        -- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
        -- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
        -- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
        -- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
        -- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
        -- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      },
    },
  },
}
