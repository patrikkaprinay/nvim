return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        numbers = function(opts)
          return tostring(opts.ordinal) -- just "1" instead of "1."
        end,
      },
    },
  },
}
