-- vim-tmux-navigator (C-h/j/k/l across nvim splits and tmux panes; pairs with is_vim in tmux.conf)
return {
  "christoomey/vim-tmux-navigator",
  cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious" },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  -- <leader>h/j/k/l is the same motion under the leader (tmux: prefix + h/j/k/l)
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
    { "<leader>h", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
    { "<leader>j", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
    { "<leader>k", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
    { "<leader>l", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
  },
}
