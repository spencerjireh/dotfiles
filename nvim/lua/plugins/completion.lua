-- Completion (blink.cmp) and bracket auto-pairing
return {
  -- Completion (blink.cmp: LSP, path, snippets, buffer; prebuilt fuzzy matcher)
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tag pulls the prebuilt Rust fuzzy binary
    event = "InsertEnter",
    opts = {
      keymap = {
        preset = "enter", -- <CR> accept, <C-e> hide, <C-b>/<C-f> scroll docs, <C-space> show
        -- <C-space> is the tmux prefix and never reaches Neovim inside tmux; <C-n>
        -- opens the menu when hidden and moves down when open.
        ["<C-n>"] = { "show", "select_next", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
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
}
