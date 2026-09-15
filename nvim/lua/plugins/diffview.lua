-- diffview.nvim (side-by-side diffs of the working tree or a revision, file and repo history)
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  opts = {},
  keys = {
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree (diffview)" },
    { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (diffview)" },
    { "<leader>gh", ":'<,'>DiffviewFileHistory<cr>", mode = "x", desc = "History of selected lines (diffview)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history (diffview)" },
  },
}
