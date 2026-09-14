-- Leader keys - set before lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- No remote-plugin providers: nothing here uses them, and skipping the lookup
-- removes provider checks from startup and :checkhealth
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes" -- fixed width so gitsigns/diagnostics do not shift text

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- Search settings
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Persistent undo
vim.opt.undofile = true

-- Swap files - disable them
vim.opt.swapfile = false

-- Mouse support
vim.opt.mouse = "a"

-- Terminal colors
vim.opt.termguicolors = true

-- Windows and scrolling
vim.opt.scrolloff = 8 -- keep 8 lines above/below the cursor
vim.opt.splitright = true -- vertical splits open to the right
vim.opt.splitbelow = true -- horizontal splits open below
vim.opt.breakindent = true -- wrapped lines keep their indent (markdown)

-- Disable word wrap
vim.opt.wrap = false
vim.opt.sidescroll = 1 -- Smooth horizontal scrolling
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible when scrolling horizontally

-- Hide end-of-buffer tildes
vim.opt.fillchars:append({ eob = " " })

-- Auto-reload files changed outside of Neovim
vim.opt.updatetime = 250 -- Faster CursorHold for quicker external change detection
vim.opt.autoread = true

-- Trigger checktime on focus/buffer changes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("dotfiles_checktime", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Notify only on conflict: buffer modified AND file changed externally
-- Silent reload is handled by autoread; only surface the dangerous case
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("dotfiles_conflict", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.modified then
      vim.notify(
        "CONFLICT: Buffer has unsaved changes but file was modified externally.\nUse <leader>fu (undo history) to reconcile.",
        vim.log.levels.ERROR
      )
    end
  end,
})

-- Markdown-specific settings for better reading
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles_markdown", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2 -- Hide markup syntax
    vim.opt_local.concealcursor = "" -- Don't reveal on cursor line
    vim.opt_local.wrap = true -- Wrap long lines
    vim.opt_local.linebreak = true -- Break at word boundaries
    vim.opt_local.spell = true -- Enable spell check
  end,
})

-- Manual reload keymap
vim.keymap.set("n", "<leader>cr", "<cmd>checktime<cr>", { desc = "Check/reload files" })

-- Toggle word wrap
vim.keymap.set("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })

-- Open markdown file in default browser
vim.keymap.set("n", "<leader>mp", function()
  local file = vim.fn.expand("%:p")
  if file:match("%.md$") then
    vim.ui.open(file) -- open on macOS, xdg-open on Linux
  else
    vim.notify("Not a markdown file", vim.log.levels.WARN)
  end
end, { desc = "Open markdown in browser" })

-- Clear search highlights (also handled by multicursor.nvim's <Esc> cascade)

-- Folding options (for nvim-ufo)
vim.opt.foldcolumn = "0" -- Disable fold column (we'll use virtual text instead)
vim.opt.foldlevel = 99 -- Start with all folds open
vim.opt.foldlevelstart = 99 -- Start with all folds open when opening a file
vim.opt.foldenable = true -- Enable folding

-- which-key helper keymaps
vim.keymap.set("n", "<leader>?", "<cmd>WhichKey<cr>", { desc = "Show all keymaps" })
vim.keymap.set("n", "<leader><leader>", "<cmd>WhichKey <leader><cr>", { desc = "Show leader keymaps" })

-- Quit (<leader>w = format + save lives in the conform.nvim spec)
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })

-- Window navigation: <C-h/j/k/l> via vim-tmux-navigator (see its spec below)

-- Jump navigation
vim.keymap.set("n", "gh", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "gl", "<C-i>", { desc = "Jump forward" })

-- Search for visually selected text
vim.keymap.set("v", "*", function()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg("v")
  text = vim.fn.escape(text, [[\/]])
  vim.fn.setreg("/", text)
  vim.opt.hlsearch = true
  vim.cmd("normal! `<")
end, { desc = "Search for visual selection" })

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = true, -- Show error messages at end of line
  signs = false, -- Hide signs in the gutter (no more W, E, etc.)
  underline = true, -- Underline problematic code
  update_in_insert = false, -- Don't update diagnostics while typing
  severity_sort = true, -- Sort by severity
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Vesper theme
    {
      "datsfilipe/vesper.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        require("vesper").setup({
          transparent = true,
          italics = {
            comments = true,
            keywords = true,
            functions = true,
            strings = true,
            variables = true,
          },
        })
        vim.cmd.colorscheme("vesper")

        -- Customize which-key to match Vesper theme colors
        vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#101010" })
        vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#80d9c7", bg = "#101010" })
        vim.api.nvim_set_hl(0, "WhichKeyTitle", { fg = "#ffc799", bg = "#101010", bold = true })

        -- Customize floating windows (Harpoon, etc.) to match Vesper theme colors
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#101010" })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#80d9c7", bg = "#101010" })
        vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#ffc799", bg = "NONE", bold = true })

        -- Subtle cursorline
        vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1a1a1a" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffc799", bold = true })

        -- Transparent snacks explorer sidebar
        -- Link to Normal (bg=NONE via transparent Vesper) so snacks' default=true won't override
        local hl = vim.api.nvim_set_hl
        hl(0, "SnacksNormal", { link = "Normal" })
        hl(0, "SnacksNormalNC", { link = "Normal" })
        hl(0, "SnacksPicker", { link = "Normal" })
        hl(0, "SnacksPickerBox", { link = "Normal" })
        hl(0, "SnacksPickerList", { link = "Normal" })
        hl(0, "SnacksPickerInput", { link = "Normal" })
        hl(0, "SnacksWinBar", { link = "Normal" })
        hl(0, "SnacksWinBarNC", { link = "Normal" })
        hl(0, "SnacksFooter", { link = "Normal" })
        hl(0, "SnacksTitle", { fg = "#ffc799", bold = true })
        hl(0, "SnacksWinSeparator", { fg = "#505050" })
        hl(0, "SnacksPickerBorder", { fg = "#505050" })
        hl(0, "SnacksPickerBoxBorder", { fg = "#505050" })
        hl(0, "SnacksPickerBoxCursorLine", { bg = "#2a2a2a" })
        hl(0, "SnacksPickerListBorder", { fg = "#505050" })
        hl(0, "SnacksPickerListTitle", { fg = "#ffc799", bold = true })
        hl(0, "SnacksPickerListFooter", { link = "Normal" })
        hl(0, "SnacksPickerListCursorLine", { bg = "#2a2a2a" })
        hl(0, "SnacksPickerInputBorder", { fg = "#505050" })
        hl(0, "SnacksPickerInputFooter", { link = "Normal" })

        -- snacks.words: subtle background for LSP reference matches
        vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#2a2a2a" })
        vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#2a2a2a" })
        vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#2a2a2a" })
      end,
    },

    -- snacks.nvim (explorer, picker, notifications, input, words, indent, scroll, bigfile)
    {
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
    },

    -- auto-save.nvim (keep disk in sync with buffer edits)
    {
      "okuuva/auto-save.nvim",
      event = { "InsertLeave", "TextChanged" },
      opts = {
        enabled = true,
        trigger_events = {
          immediate_save = { "BufLeave", "FocusLost" },
          defer_save = { "InsertLeave", "TextChanged" },
        },
        condition = function(buf)
          local buftype = vim.bo[buf].buftype
          if buftype ~= "" then
            return false
          end
          if vim.bo[buf].readonly or not vim.bo[buf].modifiable then
            return false
          end
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname == "" then
            return false
          end
          local ok, stats = pcall(vim.uv.fs_stat, bufname)
          if ok and stats and stats.size > 1024 * 1024 then
            return false
          end
          return true
        end,
        write_all_buffers = false,
        noautocmd = false,
        debounce_delay = 1000,
      },
    },

    -- Lualine
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup({
          options = {
            theme = "auto",
            icons_enabled = true,
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
          },
        })
      end,
    },

    -- Treesitter (main branch: parser/query installer; highlight + indent wired per buffer)
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "main",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        local ts = require("nvim-treesitter")
        ts.setup({}) -- install_dir defaults to stdpath("data") .. "/site"

        local ensure = {
          "c",
          "cpp",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
          "tsx",
          "typescript",
          "javascript",
          "python",
          "go",
          "rust",
          "java",
          "json",
          "yaml",
          "toml",
          "bash",
          "html",
          "css",
        }
        local installed = {}
        for _, lang in ipairs(ts.get_installed("parsers")) do
          installed[lang] = true
        end
        local missing = vim.tbl_filter(function(lang)
          return not installed[lang]
        end, ensure)
        if #missing > 0 then
          local task = ts.install(missing, { summary = true }) -- async
          if vim.env.NVIM_TS_SYNC then
            task:wait(300000) -- bootstrap / dotup: block up to 5 min
          else
            task:await(function()
              vim.schedule(function()
                vim.notify(
                  "Treesitter: installed " .. table.concat(missing, ", ") .. " (reopen buffers with :e)",
                  vim.log.levels.INFO
                )
              end)
            end)
          end
        end

        -- Highlight + indent for any filetype that has a parser. Folds are owned by nvim-ufo.
        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true }),
          callback = function(ev)
            local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
            if not vim.treesitter.language.add(lang) then
              return -- no parser for this filetype: silent no-op
            end
            pcall(vim.treesitter.start, ev.buf, lang)
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })
      end,
    },

    -- Treesitter text objects (main branch): move + swap only; selection is handled by mini.ai
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
      event = "VeryLazy",
      init = function()
        vim.g.no_plugin_maps = true -- disable built-in ftplugin maps that clash with ]] [[ etc.
      end,
      opts = {
        select = { lookahead = true },
        move = { set_jumps = true },
      },
      config = function(_, opts)
        require("nvim-treesitter-textobjects").setup(opts)
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")

        local moves = {
          { "]f", move.goto_next_start, "@function.outer", "Next function" },
          { "[f", move.goto_previous_start, "@function.outer", "Previous function" },
          { "]c", move.goto_next_start, "@class.outer", "Next class" },
          { "[c", move.goto_previous_start, "@class.outer", "Previous class" },
          { "]a", move.goto_next_start, "@parameter.inner", "Next argument" },
          { "[a", move.goto_previous_start, "@parameter.inner", "Previous argument" },
          { "]l", move.goto_next_start, "@loop.outer", "Next loop" },
          { "[l", move.goto_previous_start, "@loop.outer", "Previous loop" },
        }
        for _, m in ipairs(moves) do
          vim.keymap.set({ "n", "x", "o" }, m[1], function()
            m[2](m[3], "textobjects")
          end, { desc = m[4] })
        end

        vim.keymap.set("n", "]s", function()
          swap.swap_next("@parameter.inner")
        end, { desc = "Swap parameter next" })
        vim.keymap.set("n", "[s", function()
          swap.swap_previous("@parameter.inner")
        end, { desc = "Swap parameter prev" })
      end,
    },

    -- LSP
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "saghen/blink.cmp",
      },
      config = function()
        require("mason").setup({
          ui = { border = "rounded" },
          log_level = vim.log.levels.WARN,
        })
        require("mason-lspconfig").setup({
          ensure_installed = {
            "lua_ls",
            "pyright",
            "tsgo", -- TypeScript 7 native server (ts_ls needs the removed JS tsserver)
            "gopls",
            "rust_analyzer",
            "jdtls",
            "clangd",
          },
        })

        -- mason-lspconfig v2 enables every installed server automatically;
        -- only per-server settings need vim.lsp.config here.
        local capabilities = require("blink.cmp").get_lsp_capabilities()
        vim.lsp.config("*", { capabilities = capabilities })

        -- ruff comes from brew (Brewfile), not mason, so enable it explicitly.
        -- It provides fix/organize-imports code actions; pyright keeps hover.
        vim.lsp.enable("ruff")

        vim.lsp.config("lua_ls", {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        })

        -- Buffer-local keymaps. K stays global (nvim-ufo peek, then hover).
        -- Navigation goes through snacks pickers (preview + multi-result);
        -- built-ins grn/gra/grt/gO stay as they are.
        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("dotfiles_lsp", { clear = true }),
          callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client.name == "ruff" then
              client.server_capabilities.hoverProvider = false -- pyright owns hover
            end

            local function map(lhs, rhs, desc)
              vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
            end
            map("gd", function()
              Snacks.picker.lsp_definitions()
            end, "Go to definition")
            map("grr", function()
              Snacks.picker.lsp_references()
            end, "References")
            map("gri", function()
              Snacks.picker.lsp_implementations()
            end, "Implementations")
            map("<leader>rn", vim.lsp.buf.rename, "Rename")
            map("<leader>ca", vim.lsp.buf.code_action, "Code action")
            map("<leader>th", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
            end, "Toggle inlay hints")
          end,
        })
      end,
    },

    -- Trouble (Diagnostics panel)
    {
      "folke/trouble.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      cmd = "Trouble",
      opts = {},
      keys = {
        {
          "<leader>xx",
          "<cmd>Trouble diagnostics toggle<cr>",
          desc = "Toggle diagnostics (Trouble)",
        },
        {
          "<leader>xX",
          "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
          desc = "Buffer diagnostics (Trouble)",
        },
        {
          "<leader>cs",
          "<cmd>Trouble symbols toggle focus=false<cr>",
          desc = "Symbols (Trouble)",
        },
        {
          "<leader>cl",
          "<cmd>Trouble lsp toggle focus=false win.position=left<cr>",
          desc = "LSP definitions / references / ... (Trouble)",
        },
        {
          "<leader>xL",
          "<cmd>Trouble loclist toggle<cr>",
          desc = "Location List (Trouble)",
        },
        {
          "<leader>xQ",
          "<cmd>Trouble qflist toggle<cr>",
          desc = "Quickfix List (Trouble)",
        },
      },
    },

    -- Completion (blink.cmp: LSP, path, snippets, buffer; prebuilt fuzzy matcher)
    {
      "saghen/blink.cmp",
      version = "1.*", -- release tag pulls the prebuilt Rust fuzzy binary
      event = "InsertEnter",
      opts = {
        keymap = {
          preset = "enter", -- <CR> accept, <C-e> hide, <C-b>/<C-f> scroll docs, <C-space> show
          ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
          ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        },
        completion = {
          list = { selection = { preselect = true, auto_insert = false } },
          documentation = { auto_show = true },
        },
        sources = { default = { "lsp", "path", "snippets", "buffer" } },
        fuzzy = { implementation = "prefer_rust_with_warning" },
      },
    },

    -- Autopairs
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("nvim-autopairs").setup({})
      end,
    },

    -- Gitsigns
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup({
          on_attach = function(bufnr)
            local gs = require("gitsigns")
            local map = function(mode, l, r, desc)
              vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
            end
            map("n", "]h", function()
              gs.nav_hunk("next")
            end, "Next hunk")
            map("n", "[h", function()
              gs.nav_hunk("prev")
            end, "Previous hunk")
            map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
            map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
            map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
            map("n", "<leader>gb", gs.blame_line, "Blame line")
            map("n", "<leader>gd", gs.diffthis, "Diff this")
          end,
        })
      end,
    },

    -- Harpoon (quick file navigation)
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },
      event = "VeryLazy",
      config = function()
        local harpoon = require("harpoon")

        harpoon:setup({
          settings = {
            save_on_toggle = false,
            sync_on_ui_close = true,
            key = function()
              return vim.uv.cwd()
            end,
          },
          menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
          },
        })

        -- Keymaps using <leader>o prefix
        vim.keymap.set("n", "<leader>oa", function()
          harpoon:list():add()
        end, { desc = "Add file to Harpoon" })

        vim.keymap.set("n", "<leader>oo", function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Open Harpoon menu" })

        -- Quick jump to marks 1-5
        for i = 1, 5 do
          vim.keymap.set("n", "<leader>o" .. i, function()
            harpoon:list():select(i)
          end, { desc = "Jump to Harpoon mark " .. i })
        end

        -- Navigate between marks
        vim.keymap.set("n", "<leader>on", function()
          harpoon:list():next()
        end, { desc = "Next Harpoon mark" })

        vim.keymap.set("n", "<leader>op", function()
          harpoon:list():prev()
        end, { desc = "Previous Harpoon mark" })
      end,
    },

    -- which-key.nvim (keymap hints)
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      config = function()
        local wk = require("which-key")

        wk.setup({
          preset = "modern",
          delay = 500,
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
          { "<leader>x", group = "Diagnostics (Trouble)" },
          { "<leader>c", group = "Code/LSP" },
          { "<leader>t", group = "Toggle" },
          { "<leader>m", group = "Markdown" },
          { "<leader>i", group = "Images/Files" },
          { "<leader>o", group = "Harpoon" },
          { "<leader>g", group = "Git" },
          { "<leader>n", group = "Notifications" },
          { "<Esc>", desc = "Clear highlights / cursors" },
          { "z", group = "Folds" },
          { "za", desc = "Toggle fold under cursor" },
          { "zc", desc = "Close fold under cursor" },
          { "zo", desc = "Open fold under cursor" },
          { "zj", desc = "Move to next fold" },
          { "zk", desc = "Move to previous fold" },
        })
      end,
    },

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

    -- UFO (Ultra Fold with LSP/Treesitter support)
    {
      "kevinhwang91/nvim-ufo",
      dependencies = {
        "kevinhwang91/promise-async",
      },
      event = "VeryLazy",
      config = function()
        -- UFO uses foldmethod 'expr' internally
        vim.o.foldmethod = "expr"
        vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

        local ufo = require("ufo")

        -- Custom fold text handler for beautiful inline fold preview
        local handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = ("  %d lines"):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0

          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end

          table.insert(newVirtText, { suffix, "MoreMsg" })
          return newVirtText
        end

        -- Tell UFO to use Treesitter as the provider
        ufo.setup({
          fold_virt_text_handler = handler,
          provider_selector = function(bufnr, filetype, buftype)
            return { "treesitter", "indent" }
          end,
          -- Preview folded content when hovering
          preview = {
            win_config = {
              border = { "", "─", "", "", "", "─", "", "" },
              winhighlight = "Normal:Folded",
              winblend = 0,
            },
            mappings = {
              scrollU = "<C-u>",
              scrollD = "<C-d>",
              jumpTop = "[",
              jumpBot = "]",
            },
          },
        })

        -- Folding keymaps
        vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
        vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
        vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "Open folds except kinds" })
        vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "Close folds with" })
        vim.keymap.set("n", "K", function()
          local winid = ufo.peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end, { desc = "Peek fold or LSP hover" })
      end,
    },

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
      event = "VeryLazy",
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

    -- vim-tmux-navigator (C-h/j/k/l across nvim splits and tmux panes; pairs with is_vim in tmux.conf)
    {
      "christoomey/vim-tmux-navigator",
      cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious" },
      init = function()
        vim.g.tmux_navigator_no_mappings = 1
      end,
      keys = {
        { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
        { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
        { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
        { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
      },
    },

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

    -- conform.nvim (explicit format + save on <leader>w; auto-save.nvim writes without formatting)
    {
      "stevearc/conform.nvim",
      cmd = { "ConformInfo" },
      keys = {
        {
          "<leader>w",
          function()
            -- synchronous when no callback is given, so the write sees the formatted buffer
            require("conform").format({ lsp_format = "fallback", timeout_ms = 500 })
            vim.cmd.write()
          end,
          desc = "Format and save",
        },
      },
      opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_organize_imports", "ruff_format" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          go = { "gofmt" },
          java = { "google-java-format" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          rust = { "rustfmt" },
        },
      },
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

    -- nvim-lint (linting beyond LSP)
    {
      "mfussenegger/nvim-lint",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
          python = { "ruff" },
          javascript = { "eslint_d" },
          typescript = { "eslint_d" },
          typescriptreact = { "eslint_d" },
          javascriptreact = { "eslint_d" },
        }
        -- eslint_d only makes sense inside a project that configures eslint
        local eslint_markers = {
          "eslint.config.js",
          "eslint.config.mjs",
          "eslint.config.cjs",
          "eslint.config.ts",
          ".eslintrc",
          ".eslintrc.js",
          ".eslintrc.cjs",
          ".eslintrc.json",
          ".eslintrc.yml",
          ".eslintrc.yaml",
        }
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
          group = vim.api.nvim_create_augroup("dotfiles_lint", { clear = true }),
          callback = function(ev)
            -- Only run linters that exist on PATH and apply to this project
            local linters = lint.linters_by_ft[vim.bo[ev.buf].filetype] or {}
            local available = vim.tbl_filter(function(name)
              if vim.fn.executable(name) ~= 1 then
                return false
              end
              if name == "eslint_d" and not vim.fs.root(ev.buf, eslint_markers) then
                return false
              end
              return true
            end, linters)
            if #available > 0 then
              lint.try_lint(available)
            end
          end,
        })
      end,
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
            Snacks.picker.pick(
              vim.tbl_deep_extend("force", require("todo-comments.snacks").source, { title = "TODOs" })
            )
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

    -- treesitter-context (sticky function/class header)
    {
      "nvim-treesitter/nvim-treesitter-context",
      event = "VeryLazy",
      opts = {
        enable = true,
        max_lines = 3,
        trim_scope = "outer",
        separator = "─",
      },
      config = function(_, opts)
        require("treesitter-context").setup(opts)
        vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#181818" })
        vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#2a2a2a" })
      end,
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
  },
  install = { colorscheme = { "vesper" } },
  checker = { enabled = false },
  performance = {
    rtp = {
      -- netrw is replaced by snacks explorer (replace_netrw) and gx is a core mapping since 0.10
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin" },
    },
  },
})

-- External file opener for PDFs and Office documents
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("dotfiles_binary", { clear = true }),
  pattern = { "*.pdf", "*.docx", "*.xlsx", "*.pptx", "*.doc", "*.xls", "*.ppt" },
  callback = function()
    vim.bo.filetype = "binary"
    vim.notify("Binary file detected. Use <leader>io to open externally.", vim.log.levels.INFO)
  end,
})

-- Keymap to open current file with system default app
vim.keymap.set("n", "<leader>io", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to open", vim.log.levels.WARN)
    return
  end

  local _, err = vim.ui.open(file) -- open on macOS, xdg-open on Linux
  if err then
    vim.notify("Failed to open file: " .. err, vim.log.levels.ERROR)
  else
    vim.notify("Opened: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
  end
end, { desc = "Open file externally" })
