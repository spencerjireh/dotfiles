-- UI extras: scrollbar (satellite), cmdline/messages (noice), inline color previews (colorizer)
return {
  -- Satellite (scrollbar with decorations)
  {
    "lewis6991/satellite.nvim",
    config = function()
      require("satellite").setup({
        current_only = false,
        winblend = 0,
        width = 4,
        handlers = {
          cursor = {
            enable = true,
          },
          search = {
            enable = true,
          },
          diagnostic = {
            enable = true,
          },
          gitsigns = {
            enable = true,
          },
          marks = {
            enable = true,
            show_builtins = false,
          },
        },
      })
    end,
  },

  -- noice.nvim (modern UI for cmdline, messages, notifications)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        },
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
      },
      -- Routine messages go to the fading one-liner bottom-right (the same
      -- view as LSP progress) instead of a toast. They still land in
      -- :messages and :Noice history.
      routes = {
        { filter = { event = "msg_show", kind = "", find = "written" }, view = "mini" },
        { filter = { event = "msg_show", kind = "", find = "lines yanked" }, view = "mini" },
        { filter = { event = "msg_show", kind = "", find = "fewer lines" }, view = "mini" },
        { filter = { event = "msg_show", kind = "", find = "more lines" }, view = "mini" },
        { filter = { event = "msg_show", kind = "", find = "line less" }, view = "mini" },
        { filter = { event = "msg_show", kind = "", find = "before #" }, view = "mini" }, -- undo
        { filter = { event = "msg_show", kind = "", find = "after #" }, view = "mini" }, -- redo
        { filter = { event = "msg_show", kind = "wmsg" }, view = "mini" }, -- search hit BOTTOM/TOP
        { filter = { event = "msg_show", kind = "emsg", find = "E486" }, view = "mini" }, -- pattern not found
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        progress = {
          enabled = true,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
        inc_rename = true, -- IncRename prompt as a cmdline popup
      },
    },
  },

  -- nvim-colorizer (inline color previews; catgoose fork, maintained)
  {
    "catgoose/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        css = true,
        css_fn = true,
      },
    },
  },
}
