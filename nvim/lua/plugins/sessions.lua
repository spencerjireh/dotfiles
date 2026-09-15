-- persistence.nvim (a session per working directory, saved on exit; <leader>s...)
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    {
      "<leader>ss",
      function()
        require("persistence").load()
      end,
      desc = "Restore session for this directory",
    },
    {
      "<leader>sl",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore last session",
    },
    {
      "<leader>sd",
      function()
        require("persistence").stop()
      end,
      desc = "Do not save this session",
    },
  },
}
