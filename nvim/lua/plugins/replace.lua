-- grug-far.nvim (project-wide find and replace: ripgrep search buffer with live results)
return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  opts = { headerMaxWidth = 80 },
  keys = {
    {
      "<leader>fR",
      function()
        require("grug-far").open()
      end,
      desc = "Find and replace (grug-far)",
    },
    {
      "<leader>fR",
      function()
        require("grug-far").with_visual_selection()
      end,
      mode = "x",
      desc = "Find and replace selection (grug-far)",
    },
  },
}
