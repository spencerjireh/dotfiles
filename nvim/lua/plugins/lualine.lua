-- Lualine (statusline). lualine_x starts with what the repo activated for this buffer:
-- "lsp:<clients> fmt:<formatters|none> lint:<linters>" (lua/dotfiles/project.lua).
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        icons_enabled = require("dotfiles.settings").on("GLYPHS"), -- off without a Nerd Font
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_x = {
          require("dotfiles.project").status,
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    })
  end,
}
