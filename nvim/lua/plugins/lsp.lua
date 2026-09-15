-- LSP: nvim-lspconfig + mason, servers installed on demand, SchemaStore for JSON/YAML,
-- lazydev for Lua, inc-rename for live-preview renames
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      { "b0o/SchemaStore.nvim", lazy = true }, -- loaded by jsonls/yamlls before_init
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

      -- pyright reads [tool.pyright] / pyrightconfig.json itself. Without either,
      -- an untyped repo gets "basic" checking instead of pyright's stricter default.
      vim.lsp.config("pyright", {
        before_init = function(_, config)
          local root = config.root_dir
          local has_config = root
            and (
              vim.uv.fs_stat(root .. "/pyrightconfig.json")
              or require("dotfiles.project").pyproject_has(root .. "/pyproject.toml", "tool.pyright")
            )
          if not has_config then
            config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
              python = { analysis = { typeCheckingMode = "basic" } },
            })
          end
        end,
      })

      -- SchemaStore: package.json, tsconfig, pyproject, GitHub workflows, compose files,
      -- Kubernetes and more get completion and validation. Loaded when the server starts.
      vim.lsp.config("jsonls", {
        before_init = function(_, config)
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
          })
        end,
      })
      vim.lsp.config("yamlls", {
        before_init = function(_, config)
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            yaml = {
              schemaStore = { enable = false, url = "" }, -- SchemaStore.nvim supplies the catalog
              schemas = require("schemastore").yaml.schemas(),
            },
          })
        end,
      })

      -- Servers installed on first use. Key: filetype. Value: lspconfig server names;
      -- a table entry carries `markers` so the server is installed only inside repos
      -- that use it (biome). Mason installs into its own directory, never into the repo.
      -- mason-lspconfig enables a server as soon as its package installs, and
      -- vim.lsp.enable attaches it to buffers that are already open.
      local biome = { "biome", markers = { "biome.json", "biome.jsonc" } }
      local on_demand = {
        sh = { "bashls" },
        bash = { "bashls" },
        json = { "jsonls", biome },
        jsonc = { "jsonls", biome },
        yaml = { "yamlls" },
        ["yaml.docker-compose"] = { "yamlls" },
        toml = { "taplo" },
        dockerfile = { "dockerls" },
        html = { "html" },
        css = { "cssls", biome },
        scss = { "cssls" },
        less = { "cssls" },
        markdown = { "marksman" },
        javascript = { biome },
        javascriptreact = { biome },
        typescript = { biome },
        typescriptreact = { biome },
        ruby = { "ruby_lsp" },
        php = { "intelephense" },
        elixir = { "elixirls" },
        zig = { "zls" },
        svelte = { "svelte" },
        vue = { "vue_ls" },
        astro = { "astro" },
        prisma = { "prismals" },
        terraform = { "terraformls" },
        ["terraform-vars"] = { "terraformls" },
        nix = { "nil_ls" },
        kotlin = { "kotlin_language_server" },
        graphql = { "graphql" },
        proto = { "buf_ls" },
        cmake = { "neocmake" },
      }
      local attempted = {} ---@type table<string, boolean> server names tried this session

      local function install_server(server, ft)
        local registry = require("mason-registry")
        registry.refresh(vim.schedule_wrap(function()
          local pkg_name = require("mason-lspconfig").get_mappings().lspconfig_to_package[server]
          if not pkg_name or not registry.has_package(pkg_name) then
            return
          end
          local pkg = registry.get_package(pkg_name)
          if pkg:is_installed() or pkg:is_installing() then
            return
          end
          vim.notify(("Installing %s for %s files"):format(server, ft), vim.log.levels.INFO)
          pkg:once("install:success", function()
            vim.schedule(function()
              vim.notify(("%s installed and attached"):format(server), vim.log.levels.INFO)
            end)
          end)
          pkg:once("install:failed", function()
            vim.schedule(function()
              vim.notify(("%s install failed (:MasonLog)"):format(server), vim.log.levels.WARN)
            end)
          end)
          pkg:install()
        end))
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("dotfiles_lsp_on_demand", { clear = true }),
        callback = function(ev)
          local entries = on_demand[ev.match]
          if not entries or vim.bo[ev.buf].buftype ~= "" then
            return
          end
          for _, entry in ipairs(entries) do
            local server = type(entry) == "table" and entry[1] or entry
            local markers = type(entry) == "table" and entry.markers or nil
            if not attempted[server] and not vim.lsp.is_enabled(server) then
              if not markers or vim.fs.root(ev.buf, markers) then
                attempted[server] = true
                install_server(server, ev.match)
              end
            end
          end
        end,
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

      -- What is attached, and why not: the statusline shows lsp:/fmt:/lint:, this shows detail
      vim.keymap.set("n", "<leader>tl", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP status (checkhealth)" })
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
