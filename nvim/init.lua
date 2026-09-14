-- Neovim config entry point.
--
-- Layout:
--   init.lua              options, autocmds, keymaps that need no plugin, lazy.nvim bootstrap
--   lua/plugins/*.lua     one file per purpose (lsp, completion, git, debug, ...); each returns
--                         a lazy.nvim spec (or a list of specs) and is picked up by the
--                         { import = "plugins" } line below. Add a plugin = add a file.
--
-- Keymap reference: docs/nvim.md in the dotfiles repo (`dot keys nvim`).

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
vim.o.winborder = "rounded" -- default border for every floating window (hover, signature, pickers)

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

-- Manual reload keymap (autoread + the checktime autocmd above cover the normal case)
vim.keymap.set("n", "<leader>tR", "<cmd>checktime<cr>", { desc = "Reload files from disk" })

-- Toggles (<leader>t...) are defined with Snacks.toggle in lua/plugins/snacks.lua

-- Open markdown file in default browser
vim.keymap.set("n", "<leader>mp", function()
  local file = vim.fn.expand("%:p")
  if file:match("%.md$") then
    vim.ui.open(file) -- open on macOS, xdg-open on Linux
  else
    vim.notify("Not a markdown file", vim.log.levels.WARN)
  end
end, { desc = "Open markdown in browser" })

-- Clear search highlights: multicursor.nvim's <Esc> cascade (lua/plugins/editing.lua)

-- Folding options (for nvim-ufo)
vim.opt.foldcolumn = "0" -- Disable fold column (we'll use virtual text instead)
vim.opt.foldlevel = 99 -- Start with all folds open
vim.opt.foldlevelstart = 99 -- Start with all folds open when opening a file
vim.opt.foldenable = true -- Enable folding

-- which-key helper keymaps
vim.keymap.set("n", "<leader>?", "<cmd>WhichKey<cr>", { desc = "Show all keymaps" })
vim.keymap.set("n", "<leader><leader>", "<cmd>WhichKey <leader><cr>", { desc = "Show leader keymaps" })

-- Quit (<leader>w = format + save lives in lua/plugins/format.lua)
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })

-- Window navigation: <C-h/j/k/l> via vim-tmux-navigator (lua/plugins/tmux-navigator.lua)

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

-- Setup lazy.nvim: every file in lua/plugins/ is a plugin spec
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "vesper" } },
  checker = { enabled = false },
  rocks = { enabled = false }, -- nothing here needs luarocks; silences the hererocks health check
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
