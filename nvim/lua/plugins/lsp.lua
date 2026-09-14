-- LSP: nvim-lspconfig + mason, lazydev for Lua, inc-rename for live-preview renames
return {
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
          "rust_analyzer", -- binary only; rustaceanvim starts it (excluded from auto-enable below)
          "jdtls",
          "clangd",
        },
        automatic_enable = { exclude = { "rust_analyzer" } },
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
            -- workspace.library is supplied lazily by lazydev.nvim
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
          -- inc-rename: live preview of the rename across the buffer
          vim.keymap.set("n", "<leader>rn", function()
            return ":IncRename " .. vim.fn.expand("<cword>")
          end, { buffer = ev.buf, expr = true, desc = "Rename (live preview)" })
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },

  -- lazydev.nvim (lua_ls: load only the runtime/plugin sources a file references)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- inc-rename.nvim (LSP rename with live preview; mapped to <leader>rn on LspAttach)
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },
}
