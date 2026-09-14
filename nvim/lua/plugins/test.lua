-- Tests: neotest (per-language adapters) and rustaceanvim (Rust LSP, debug, test adapter)
return {
  -- rustaceanvim (rust-analyzer with extras; owns Rust LSP, debugging via codelldb, neotest adapter)
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false, -- the plugin lazy-loads itself by filetype
  },

  -- neotest (run the test under the cursor; adapters per language)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "fredrikaverpil/neotest-golang",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
      "mrcjkb/rustaceanvim",
    },
    keys = {
      {
        "<leader>dt",
        function()
          require("neotest").run.run()
        end,
        desc = "Test nearest",
      },
      {
        "<leader>dT",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test file",
      },
      {
        "<leader>dD",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug nearest test",
      },
      {
        "<leader>ds",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test summary",
      },
      {
        "<leader>dp",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Test output panel",
      },
      {
        "<leader>dS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop tests",
      },
    },
    opts = function()
      -- uv/venv aware interpreter for pytest
      local function python()
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. "/bin/python"
        end
        local venv = vim.fs.find(".venv/bin/python", { upward = true, path = vim.fn.getcwd() })[1]
        return venv or "python3"
      end
      return {
        adapters = {
          require("neotest-python")({ runner = "pytest", python = python }),
          require("neotest-golang"),
          require("neotest-vitest"),
          require("neotest-jest")({ jestCommand = "npx jest" }),
          require("rustaceanvim.neotest"),
        },
      }
    end,
  },
}
