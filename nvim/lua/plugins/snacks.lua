-- snacks.nvim (explorer, picker, notifications, input, words, indent, scroll, bigfile, bufdelete)
return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    bigfile = { enabled = true }, -- trims heavy features on files > 1.5MB
    quickfile = { enabled = true },
    words = { enabled = true, debounce = 200 }, -- LSP reference highlight (replaces vim-illuminate)
    indent = { -- indent guides (replaces indent-blankline)
      enabled = true,
      indent = { char = "│" },
      scope = { enabled = true, char = "│" },
      animate = { enabled = false },
    },
    scroll = { -- smooth scrolling (replaces neoscroll)
      enabled = true,
      animate = { duration = { step = 10, total = 100 } },
    },
    explorer = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          layout = {
            preset = "sidebar",
            preview = false,
            layout = { position = "right", width = 30 },
          },
          hidden = true,
          ignored = true,
          follow_file = true,
          git_status = true,
          trash = true,
          win = {
            list = {
              keys = {
                ["x"] = "explorer_cut",
                ["c"] = { "explorer_copy", mode = { "n", "x" } },
                ["d"] = { "explorer_del", mode = { "n", "x" } },
                ["m"] = { "explorer_move", mode = { "n", "x" } },
              },
            },
          },
        },
      },
    },
    notifier = {
      enabled = true,
      timeout = 3000,
      style = "compact",
      top_down = false,
      width = { min = 30, max = 0.4 },
      margin = { top = 0, right = 1, bottom = 1 },
    },
    input = { enabled = true },
    zen = {}, -- distraction-free editing (<leader>tz)
    scratch = {}, -- persistent scratch buffers (<leader>.)
    dim = {}, -- dim everything outside the current scope (<leader>tD)
  },
  config = function(_, opts)
    local Snacks = require("snacks")
    Snacks.setup(opts)

    -- Sticky ERROR notifications (ported from nvim-notify override)
    local original_notify = vim.notify
    vim.notify = function(msg, level, o)
      o = o or {}
      if level == vim.log.levels.ERROR then
        o.timeout = false
      end
      original_notify(msg, level, o)
    end

    -- Buffer keymaps: close a file without collapsing its window
    vim.keymap.set("n", "<leader>bd", function()
      Snacks.bufdelete()
    end, { desc = "Close buffer (keep window)" })
    vim.keymap.set("n", "<leader>bo", function()
      Snacks.bufdelete.other()
    end, { desc = "Close other buffers" })

    -- Explorer keymaps
    vim.keymap.set("n", "-", function()
      Snacks.explorer.open()
    end, { desc = "Toggle file explorer" })
    vim.keymap.set("n", "<leader>e", function()
      Snacks.explorer.open()
    end, { desc = "Focus file explorer" })

    -- Notification keymaps
    vim.keymap.set("n", "<leader>nd", function()
      Snacks.notifier.hide()
    end, { desc = "Dismiss notifications" })
    vim.keymap.set("n", "<leader>nh", function()
      Snacks.notifier.show_history()
    end, { desc = "Notification history" })

    -- Picker keymaps (replaces telescope)
    vim.keymap.set("n", "<leader>ff", function()
      Snacks.picker.files()
    end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", function()
      Snacks.picker.grep()
    end, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", function()
      Snacks.picker.buffers()
    end, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", function()
      Snacks.picker.help()
    end, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fu", function()
      Snacks.picker.undo()
    end, { desc = "Undo history" })
    vim.keymap.set("n", "<leader>fr", function()
      Snacks.picker.recent()
    end, { desc = "Recent files" })
    vim.keymap.set("n", "<leader>fs", function()
      Snacks.picker.lsp_symbols()
    end, { desc = "Document symbols" })
    vim.keymap.set("n", "<leader>fd", function()
      Snacks.picker.diagnostics()
    end, { desc = "Diagnostics" })
    vim.keymap.set("n", "<leader>fk", function()
      Snacks.picker.keymaps()
    end, { desc = "Keymaps" })

    -- Words keymaps: jump between LSP references of the word under cursor
    vim.keymap.set({ "n", "t" }, "]]", function()
      Snacks.words.jump(vim.v.count1)
    end, { desc = "Next reference" })
    vim.keymap.set({ "n", "t" }, "[[", function()
      Snacks.words.jump(-vim.v.count1)
    end, { desc = "Previous reference" })

    -- Toggles: which-key shows the current state of each
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
    Snacks.toggle.option("relativenumber", { name = "Relative numbers" }):map("<leader>tn")
    Snacks.toggle.diagnostics():map("<leader>td")
    Snacks.toggle.inlay_hints():map("<leader>th")
    Snacks.toggle.indent():map("<leader>ti")
    Snacks.toggle.dim():map("<leader>tD")
    Snacks.toggle.zen():map("<leader>tz")
    Snacks.toggle.treesitter():map("<leader>tT")

    -- Git: lazygit and open-on-GitHub
    vim.keymap.set("n", "<leader>gg", function()
      Snacks.lazygit()
    end, { desc = "Lazygit" })
    vim.keymap.set("n", "<leader>gl", function()
      Snacks.lazygit.log_file()
    end, { desc = "Lazygit file log" })
    vim.keymap.set({ "n", "x" }, "<leader>go", function()
      Snacks.gitbrowse()
    end, { desc = "Open on GitHub" })

    -- Scratch buffers
    vim.keymap.set("n", "<leader>.", function()
      Snacks.scratch()
    end, { desc = "Scratch buffer" })
    vim.keymap.set("n", "<leader>S", function()
      Snacks.scratch.select()
    end, { desc = "Select scratch buffer" })

    -- Vesper highlights: notifier
    local hl = vim.api.nvim_set_hl
    local levels = {
      { "Error", "#ff8080" },
      { "Warn", "#ffc799" },
      { "Info", "#80d9c7" },
      { "Debug", "#505050" },
      { "Trace", "#505050" },
    }
    for _, l in ipairs(levels) do
      hl(0, "SnacksNotifier" .. l[1], { fg = l[2], bg = "#101010" })
      hl(0, "SnacksNotifierBorder" .. l[1], { fg = l[2] })
      hl(0, "SnacksNotifierIcon" .. l[1], { fg = l[2] })
    end
  end,
}
