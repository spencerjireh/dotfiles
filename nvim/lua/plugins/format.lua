-- conform.nvim (explicit format + save on <leader>w; auto-save.nvim writes without formatting)
return {
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
}
