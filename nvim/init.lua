-- Leader keys - set before lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Python provider (use Python 3.10+ for molten)
-- Try to find python3.12, python3.11, python3.10 in order, fallback to python3
local function find_python()
  local candidates = {
    vim.fn.exepath("python3.12"),
    vim.fn.exepath("python3.11"),
    vim.fn.exepath("python3.10"),
    vim.fn.exepath("python3"),
  }

  for _, python in ipairs(candidates) do
    if python ~= "" then
      return python
    end
  end

  return "python3" -- fallback
end

vim.g.python3_host_prog = find_python()

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

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

-- Disable word wrap
vim.opt.wrap = false
vim.opt.sidescroll = 1  -- Smooth horizontal scrolling
vim.opt.sidescrolloff = 8  -- Keep 8 columns visible when scrolling horizontally

-- Hide end-of-buffer tildes
vim.opt.fillchars:append({ eob = " " })

-- Auto-reload files changed outside of Neovim
vim.opt.autoread = true

-- Trigger checktime on focus/buffer changes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Notify when file changes externally
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

-- Markdown-specific settings for better reading
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2  -- Hide markup syntax
    vim.opt_local.concealcursor = "" -- Don't reveal on cursor line
    vim.opt_local.wrap = true        -- Wrap long lines
    vim.opt_local.linebreak = true   -- Break at word boundaries
    vim.opt_local.spell = true       -- Enable spell check
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
    vim.fn.system({ "open", file })
  else
    vim.notify("Not a markdown file", vim.log.levels.WARN)
  end
end, { desc = "Open markdown in browser" })

-- Clear search highlights
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Folding options (for nvim-ufo)
vim.opt.foldcolumn = "0" -- Disable fold column (we'll use virtual text instead)
vim.opt.foldlevel = 99 -- Start with all folds open
vim.opt.foldlevelstart = 99 -- Start with all folds open when opening a file
vim.opt.foldenable = true -- Enable folding

-- which-key helper keymaps
vim.keymap.set("n", "<leader>?", "<cmd>WhichKey<cr>", { desc = "Show all keymaps" })
vim.keymap.set("n", "<leader><leader>", "<cmd>WhichKey <leader><cr>", { desc = "Show leader keymaps" })

-- Save and quit
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })

-- Window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Move to right window" })

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
        vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#ffc799", bg = "#101010", bold = true })
      end,
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

    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
          "tsx",
          "typescript",
          "python",
        },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      },
    },

    -- LSP
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
      },
      config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = { "lua_ls", "pyright" },
        })

        -- Get capabilities from cmp
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- Setup lua_ls using new API
        vim.lsp.config("lua_ls", {
          capabilities = capabilities,
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
        vim.lsp.enable("lua_ls")

        -- Python LSP
        vim.lsp.config("pyright", { capabilities = capabilities })
        vim.lsp.enable("pyright")

        -- Add more LSP servers here as needed
        -- vim.lsp.config("ts_ls", { capabilities = capabilities })
        -- vim.lsp.enable("ts_ls")

        -- Keymaps for LSP
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
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

    -- Completion
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
          }, {
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local telescope = require("telescope")
        telescope.setup({})

        -- Keymaps
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      end,
    },

    -- Neo-tree
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        { "3rd/image.nvim", optional = true }, -- Image preview support
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = true,
          window = {
            position = "right", -- "left", "right", "top", "bottom", "float", "current"
            width = 30,
            mappings = {
              ["<space>"] = "none",
              ["H"] = "toggle_hidden", -- Shift-H to toggle hidden files
            },
          },
          filesystem = {
            filtered_items = {
              visible = true, -- Show hidden files by default
              hide_dotfiles = false,
              hide_gitignored = false,
              hide_by_name = {
                ".git",
              },
              never_show = {
                ".DS_Store",
              },
            },
            follow_current_file = {
              enabled = true,
            },
            use_libuv_file_watcher = true,
          },
        })
        
        -- Disable fold column in Neo-tree windows
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "neo-tree",
          callback = function()
            vim.opt_local.foldcolumn = "0"
            vim.opt_local.foldenable = false
          end,
        })
        
        -- Customize Neo-tree colors to match Vesper theme
        vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { fg = "#80d9c7", bg = "#101010" })
        vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { fg = "#ffc799", bg = "#101010", bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeTitleBar", { fg = "#ffc799", bg = "#101010", bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE" })
        
        vim.keymap.set("n", "-", "<CMD>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
        vim.keymap.set("n", "<leader>e", "<CMD>Neotree focus<CR>", { desc = "Focus Neo-tree" })
      end,
    },

    -- Comment.nvim
    {
      "numToStr/Comment.nvim",
      config = function()
        require("Comment").setup()
      end,
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
        require("gitsigns").setup()
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
              return vim.loop.cwd()
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

        wk.add({
          { "<leader>f", group = "Find/Files (Telescope)" },
          { "<leader>x", group = "Diagnostics (Trouble)" },
          { "<leader>c", group = "Code/LSP" },
          { "<leader>t", group = "Toggle" },
          { "<leader>m", group = "Markdown" },
          { "<leader>i", group = "Images/Files" },
          { "<leader>o", group = "Harpoon" },
          { "<leader>w", desc = "Save file" },
          { "<leader>q", desc = "Quit window" },
          { "<leader>e", desc = "Focus file explorer" },
          { "<leader>mp", desc = "Open markdown in browser" },
          { "<leader>tr", desc = "Toggle render markdown" },
          { "<leader>oa", desc = "Add to Harpoon" },
          { "<leader>oo", desc = "Open Harpoon menu" },
          { "<leader>o1", desc = "Jump to mark 1" },
          { "<leader>o2", desc = "Jump to mark 2" },
          { "<leader>o3", desc = "Jump to mark 3" },
          { "<leader>o4", desc = "Jump to mark 4" },
          { "<leader>o5", desc = "Jump to mark 5" },
          { "<leader>on", desc = "Next mark" },
          { "<leader>op", desc = "Previous mark" },
          { "<leader>h", desc = "Go to left window" },
          { "<leader>j", desc = "Go to bottom window" },
          { "<leader>k", desc = "Go to top window" },
          { "<leader>l", desc = "Go to right window" },
          { "<leader>ff", desc = "Find files" },
          { "<leader>fg", desc = "Live grep" },
          { "<leader>fb", desc = "Find buffers" },
          { "<leader>fh", desc = "Help tags" },
          { "<leader>xx", desc = "Toggle diagnostics" },
          { "<leader>xX", desc = "Buffer diagnostics" },
          { "<leader>xL", desc = "Location list" },
          { "<leader>xQ", desc = "Quickfix list" },
          { "<leader>ca", desc = "Code action" },
          { "<leader>cs", desc = "Symbols" },
          { "<leader>cl", desc = "LSP definitions/references" },
          { "<leader>cr", desc = "Check/reload files" },
          { "<leader>rn", desc = "Rename symbol" },
          { "<leader>io", desc = "Open file externally" },
          { "<leader>tw", desc = "Toggle word wrap" },
          { "gd", desc = "Go to definition" },
          { "gh", desc = "Jump back" },
          { "gl", desc = "Jump forward" },
          { "K", desc = "Peek fold or LSP hover" },
          { "<Esc>", desc = "Clear search highlights" },
          { "-", desc = "Toggle file explorer" },
          { "z", group = "Folds" },
          { "za", desc = "Toggle fold under cursor" },
          { "zc", desc = "Close fold under cursor" },
          { "zo", desc = "Open fold under cursor" },
          { "zR", desc = "Open all folds" },
          { "zM", desc = "Close all folds" },
          { "zr", desc = "Open folds except kinds" },
          { "zm", desc = "Close folds with" },
          { "zj", desc = "Move to next fold" },
          { "zk", desc = "Move to previous fold" },
          { "*", desc = "Search for visual selection", mode = "v" },
        })
      end,
    },

    -- dressing.nvim (better UI)
    {
      "stevearc/dressing.nvim",
      event = "VeryLazy",
      config = function()
        require("dressing").setup({
          input = {
            enabled = true,
            default_prompt = "Input",
            trim_prompt = true,
            title_pos = "left",
            start_in_insert = true,
            border = "rounded",
            relative = "cursor",
            prefer_width = 40,
            win_options = {
              wrap = false,
              list = true,
              listchars = "precedes:…,extends:…",
              sidescrolloff = 0,
            },
            mappings = {
              n = {
                ["<Esc>"] = "Close",
                ["<CR>"] = "Confirm",
              },
              i = {
                ["<C-c>"] = "Close",
                ["<CR>"] = "Confirm",
                ["<Up>"] = "HistoryPrev",
                ["<Down>"] = "HistoryNext",
              },
            },
          },
          select = {
            enabled = true,
            backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
            trim_prompt = true,
            telescope = require("telescope.themes").get_dropdown({
              borderchars = {
                prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
                results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
                preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
              },
              width = 0.8,
              previewer = false,
              prompt_title = false,
            }),
            builtin = {
              border = "rounded",
              relative = "editor",
            },
          },
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
          local suffix = ('  %d lines'):format(endLnum - lnum)
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
              table.insert(newVirtText, {chunkText, hlGroup})
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          
          table.insert(newVirtText, {suffix, 'MoreMsg'})
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
            enabled = false,  -- Disable heading rendering, use native treesitter
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
              download_remote_images = true,
              only_render_image_at_cursor = false,
              filetypes = { "markdown", "vimwiki" },
            },
            neorg = { enabled = false },
            html = { enabled = false },
            css = { enabled = false },
          },
          max_height_window_percentage = 50,
          window_overlap_clear_enabled = false,
          window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
          hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
        })
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
})

-- External file opener for PDFs and Office documents
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
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

  local cmd = string.format("open '%s'", file)
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("Opened: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
      else
        vim.notify("Failed to open file", vim.log.levels.ERROR)
      end
    end,
  })
end, { desc = "Open file externally" })
