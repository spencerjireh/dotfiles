-- conform.nvim: formatting follows the repo. A formatter runs only when the repo
-- carries its config (require_cwd), the repo-local binary wins over the global one,
-- and a repo with no formatter config is saved untouched. <leader>w formats and
-- saves; <leader>W formats only the changed hunks. auto-save.nvim writes without formatting.
return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>w",
      function()
        local conform = require("conform")
        local formatters = conform.list_formatters_to_run(0)
        if #formatters == 0 then
          vim.cmd.write()
          vim.notify("saved, no formatter config in this repo", vim.log.levels.INFO)
          return
        end
        -- synchronous when no callback is given, so the write sees the formatted buffer
        conform.format({ timeout_ms = 500 })
        vim.cmd.write()
      end,
      desc = "Format and save",
    },
    {
      "<leader>W",
      function()
        local conform = require("conform")
        if #conform.list_formatters_to_run(0) == 0 then
          vim.cmd.write()
          vim.notify("saved, no formatter config in this repo", vim.log.levels.INFO)
          return
        end
        local ok, gitsigns = pcall(require, "gitsigns")
        local hunks = ok and gitsigns.get_hunks(0) or nil
        if not hunks or #hunks == 0 then
          vim.cmd.write()
          vim.notify("saved, no changed hunks to format", vim.log.levels.INFO)
          return
        end
        -- Bottom-up so earlier line numbers stay valid after a hunk grows or shrinks
        for i = #hunks, 1, -1 do
          local hunk = hunks[i]
          if hunk.type ~= "delete" then
            local first = hunk.added.start
            local last = first + math.max(hunk.added.count, 1) - 1
            local last_line = vim.api.nvim_buf_get_lines(0, last - 1, last, false)[1] or ""
            conform.format({
              timeout_ms = 500,
              range = { start = { first, 0 }, ["end"] = { last, #last_line } },
            })
          end
        end
        vim.cmd.write()
      end,
      desc = "Format changed hunks and save",
    },
  },
  opts = function()
    local util = require("conform.util")
    return {
      default_format_opts = { lsp_format = "never" }, -- LSP formatting only where opted in below
      formatters = {
        -- Config-gated: the builtin cwd already resolves the config file; require_cwd
        -- turns "no config" into "not available", which stop_after_first skips.
        prettierd = { require_cwd = true },
        prettier = { require_cwd = true, command = util.from_node_modules("prettier") },
        biome = { require_cwd = true, command = util.from_node_modules("biome") },
        deno_fmt = { require_cwd = true, cwd = util.root_file({ "deno.json", "deno.jsonc" }) },
        stylua = { require_cwd = true },
        -- Python tools: the repo's .venv copy wins over the brew one
        black = { require_cwd = true, command = util.find_executable({ ".venv/bin/black" }, "black") },
        ruff_format = { require_cwd = true, command = util.find_executable({ ".venv/bin/ruff" }, "ruff") },
        ruff_organize_imports = { require_cwd = true, command = util.find_executable({ ".venv/bin/ruff" }, "ruff") },
        ["clang-format"] = { require_cwd = true, cwd = util.root_file({ ".clang-format", "_clang-format" }) },
        shfmt = { require_cwd = true, cwd = util.root_file({ ".editorconfig" }) }, -- style comes from editorconfig only
      },
      formatters_by_ft = {
        lua = { "stylua" },
        -- black, ruff (with import sorting only when the config selects "I"), or nothing
        python = function(bufnr)
          return require("dotfiles.project").python_formatters(bufnr)
        end,
        javascript = { "biome", "deno_fmt", "prettierd", "prettier", stop_after_first = true },
        typescript = { "biome", "deno_fmt", "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "deno_fmt", "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "deno_fmt", "prettierd", "prettier", stop_after_first = true },
        json = { "biome", "prettierd", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettierd", "prettier", stop_after_first = true },
        css = { "biome", "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "biome", "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        astro = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        sh = { "shfmt" },
        bash = { "shfmt" },
        -- The language's own tool is the convention; these run without a config file
        go = { "gofmt" },
        rust = { "rustfmt" },
        java = { "google-java-format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
    }
  end,
}
