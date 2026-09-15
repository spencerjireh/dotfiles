-- which-key.nvim (keymap hints; groups only, every mapping carries its own desc)
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.setup({
      preset = "modern",
      delay = 200,
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      win = {
        border = "rounded",
        padding = { 1, 2 },
        wo = {
          winblend = 30, -- 0 for fully opaque, 100 for fully transparent
        },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 0,
        align = "left",
      },
      show_help = true,
      show_keys = true,
    })

    -- Groups only; every mapping carries its own desc, which-key reads it.
    -- Built-in fold keys and <Esc> have no keymap desc, so they are listed here.
    wk.add({
      { "<leader>f", group = "Find (Snacks)" },
      { "<leader>b", group = "Buffer" },
      { "<leader>x", group = "Diagnostics (Trouble)" },
      { "<leader>c", group = "Code actions" },
      { "<leader>t", group = "Toggle / tools" },
      { "<leader>i", group = "Images/Files" },
      { "<leader>m", group = "Harpoon (marks)" },
      { "<leader>g", group = "Git" },
      { "<leader>n", group = "Notifications" },
      { "<leader>a", group = "Claude" },
      { "<leader>d", group = "Debug/Test" },
      { "<leader>s", group = "Session" },
      { "<Esc>", desc = "Clear highlights / cursors" },
      { "z", group = "Folds" },
      { "za", desc = "Toggle fold under cursor" },
      { "zc", desc = "Close fold under cursor" },
      { "zo", desc = "Open fold under cursor" },
      { "zj", desc = "Move to next fold" },
      { "zk", desc = "Move to previous fold" },
    })
  end,
}
