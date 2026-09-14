-- Editing helpers: surround, text objects, multicursor, flash jumps, TODO comments, CSV
return {
  -- nvim-surround (add/change/delete surrounding chars)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- mini.ai (a/i text objects; treesitter-backed f/c/a/i via textobjects.scm queries)
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" }, -- provides queries/*/textobjects.scm
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
          i = ai.gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
        },
      }
    end,
  },

  -- multicursor.nvim (VS Code-like multi-cursor editing)
  {
    "jake-stewart/multicursor.nvim",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      local set = vim.keymap.set
      set({ "n", "v" }, "<C-n>", function()
        mc.matchAddCursor(1)
      end, { desc = "Add cursor at next match" })
      set({ "n", "v" }, "<C-p>", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip match, add next" })
      set({ "n", "v" }, "<leader>A", function()
        mc.matchAllAddCursors()
      end, { desc = "Add cursors to all matches" })
      set("n", "<Esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        else
          vim.cmd("nohlsearch")
        end
      end)
    end,
  },

  -- flash.nvim (label-based jumping)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },

  -- todo-comments (highlight and search TODOs)
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>ft",
        function()
          -- todo-comments ships a snacks picker source but does not register it
          Snacks.picker.pick(vim.tbl_deep_extend("force", require("todo-comments.snacks").source, { title = "TODOs" }))
        end,
        desc = "Find TODOs",
      },
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next TODO",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous TODO",
      },
    },
  },

  -- Rainbow CSV (CSV/TSV syntax highlighting and querying)
  {
    "cameron-wags/rainbow_csv.nvim",
    ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace", "csv_pipe", "rfc_csv", "rfc_semicolon" },
    cmd = { "RainbowDelim", "RainbowDelimSimple", "RainbowDelimQuoted", "RainbowMultiDelim" },
    config = function()
      require("rainbow_csv").setup()
    end,
  },
}
