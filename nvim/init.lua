-- Leader keys - set before lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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

-- Terminal/transparency settings
vim.opt.termguicolors = false

vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight LineNr guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
  highlight StatusLine ctermfg=0 ctermbg=15
]])

vim.cmd([[
  autocmd ColorScheme * highlight Normal guibg=NONE ctermbg=NONE
  autocmd ColorScheme * highlight NonText guibg=NONE ctermbg=NONE
  autocmd ColorScheme * highlight LineNr guibg=NONE ctermbg=NONE
  autocmd ColorScheme * highlight SignColumn guibg=NONE ctermbg=NONE
  autocmd ColorScheme * highlight StatusLine guibg=NONE ctermbg=NONE
  autocmd ColorScheme * highlight StatusLineNC guibg=NONE ctermbg=NONE
]])

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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
    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "c",
            "lua",
            "vim",
            "vimdoc",
            "query",
            "markdown",
            "markdown_inline",
          },
          sync_install = false,
          highlight = {
            enable = true,
          },
        })
      end,
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
          ensure_installed = { "lua_ls" }, -- Add language servers you need
        })

        -- Get capabilities from cmp
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- Setup lua_ls using new API
        vim.lsp.config("lua_ls", {
          capabilities = capabilities,
        })
        vim.lsp.enable("lua_ls")

        -- Add more LSP servers here as needed
        -- vim.lsp.config("pyright", { capabilities = capabilities })
        -- vim.lsp.enable("pyright")
        -- vim.lsp.config("ts_ls", { capabilities = capabilities })
        -- vim.lsp.enable("ts_ls")

        -- Keymaps for LSP
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
      end,
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

    -- Oil.nvim
    {
      "stevearc/oil.nvim",
      config = function()
        require("oil").setup({
          default_file_explorer = true,
        })
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
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
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})
