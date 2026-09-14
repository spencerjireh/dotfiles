-- nvim-lint (linting beyond LSP)
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
}
