-- Markdown: in-buffer rendering and inline images
return {
  -- Render Markdown (in-buffer rendering)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({
        heading = {
          enabled = false, -- Disable heading rendering, use native treesitter
        },
        code = {
          enabled = true,
          sign = false,
          style = "normal",
          width = "block",
          left_pad = 1,
          right_pad = 1,
          border = "thin",
        },
        bullet = {
          enabled = true,
          icons = { "●", "○", "◆", "◇" },
        },
      })

      -- Custom Vesper colors for native markdown headings (treesitter)
      vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#ffc799", bold = true })
      vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#80d9c7", bold = true })
      vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#99ffe4", bold = true })
      vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#ffcfa8" })
      vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#a0a0a0" })
      vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#8b8b8b" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
    end,
    keys = {
      { "<leader>tr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle render markdown" },
    },
  },

  -- Image.nvim (inline image viewing with Kitty graphics protocol)
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    build = false,
    config = function()
      require("image").setup({
        backend = "kitty",
        processor = "magick_cli",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = false,
            only_render_image_at_cursor = true,
            filetypes = { "markdown", "vimwiki" },
          },
          neorg = { enabled = false },
          html = { enabled = false },
          css = { enabled = false },
        },
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { "blink-cmp-menu", "blink-cmp-documentation", "" },
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
      })
    end,
  },
}
