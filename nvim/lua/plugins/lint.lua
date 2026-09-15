-- nvim-lint (linting beyond LSP). A linter runs only when its binary is on PATH
-- and, for tools that need repo config (eslint_d, ruff), the repo carries that
-- config; the gates live in lua/dotfiles/project.lua so the statusline agrees.
return {
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
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      dockerfile = { "hadolint" },
    }
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("dotfiles_lint", { clear = true }),
      callback = function(ev)
        local available = require("dotfiles.project").linters(ev.buf)
        if #available > 0 then
          lint.try_lint(available)
        end
      end,
    })
  end,
}
