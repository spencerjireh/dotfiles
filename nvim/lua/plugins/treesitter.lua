-- Treesitter: parser installer + per-buffer highlight/indent, text-object motions, sticky context
return {
  -- Treesitter (main branch: parser/query installer; highlight + indent wired per buffer)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({}) -- install_dir defaults to stdpath("data") .. "/site"

      local ensure = {
        "c",
        "cpp",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "tsx",
        "typescript",
        "javascript",
        "python",
        "go",
        "rust",
        "java",
        "json",
        "yaml",
        "toml",
        "bash",
        "html",
        "css",
        "regex", -- snacks picker input highlighting
        "latex", -- render-markdown math
      }
      local installed = {}
      for _, lang in ipairs(ts.get_installed("parsers")) do
        installed[lang] = true
      end
      local missing = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, ensure)
      if #missing > 0 then
        local task = ts.install(missing, { summary = true }) -- async
        if vim.env.NVIM_TS_SYNC then
          task:wait(300000) -- bootstrap / dot update: block up to 5 min
        else
          task:await(function()
            vim.schedule(function()
              vim.notify(
                "Treesitter: installed " .. table.concat(missing, ", ") .. " (reopen buffers with :e)",
                vim.log.levels.INFO
              )
            end)
          end)
        end
      end

      local function attach(buf, lang)
        pcall(vim.treesitter.start, buf, lang)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      -- Parsers installed on first use: a filetype with an installable parser that is
      -- not on disk yet gets it in the background, then every buffer of that filetype
      -- is attached. get_available() is cached because each call fires a User autocmd.
      local available ---@type table<string, boolean>|nil
      local attempted = {} ---@type table<string, boolean>
      local function install_on_demand(lang, ft)
        if not available then
          available = {}
          for _, l in ipairs(require("nvim-treesitter.config").get_available()) do
            available[l] = true
          end
        end
        if attempted[lang] or not available[lang] then
          return
        end
        attempted[lang] = true
        ts.install({ lang }):await(function(err)
          vim.schedule(function()
            if err then
              vim.notify(("Treesitter: %s parser failed to install (:TSLog)"):format(lang), vim.log.levels.WARN)
              return
            end
            if not vim.treesitter.language.add(lang) then
              return
            end
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == ft then
                attach(buf, lang)
              end
            end
            vim.notify(("Treesitter: installed %s"):format(lang), vim.log.levels.INFO)
          end)
        end)
      end

      -- Highlight + indent for any filetype that has a parser. Folds are owned by nvim-ufo.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
          if not vim.treesitter.language.add(lang) then
            if vim.bo[ev.buf].buftype == "" then
              install_on_demand(lang, ev.match)
            end
            return
          end
          attach(ev.buf, lang)
        end,
      })
    end,
  },

  -- Treesitter text objects (main branch): move + swap only; selection is handled by mini.ai
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    init = function()
      vim.g.no_plugin_maps = true -- disable built-in ftplugin maps that clash with ]] [[ etc.
    end,
    opts = {
      select = { lookahead = true },
      move = { set_jumps = true },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local moves = {
        { "]f", move.goto_next_start, "@function.outer", "Next function" },
        { "[f", move.goto_previous_start, "@function.outer", "Previous function" },
        { "]c", move.goto_next_start, "@class.outer", "Next class" },
        { "[c", move.goto_previous_start, "@class.outer", "Previous class" },
        { "]a", move.goto_next_start, "@parameter.inner", "Next argument" },
        { "[a", move.goto_previous_start, "@parameter.inner", "Previous argument" },
        { "]l", move.goto_next_start, "@loop.outer", "Next loop" },
        { "[l", move.goto_previous_start, "@loop.outer", "Previous loop" },
      }
      for _, m in ipairs(moves) do
        vim.keymap.set({ "n", "x", "o" }, m[1], function()
          m[2](m[3], "textobjects")
        end, { desc = m[4] })
      end

      vim.keymap.set("n", "]s", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap parameter next" })
      vim.keymap.set("n", "[s", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap parameter prev" })
    end,
  },

  -- treesitter-context (sticky function/class header)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      enable = true,
      max_lines = 3,
      trim_scope = "outer",
      separator = "─",
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#181818" })
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#2a2a2a" })
    end,
  },
}
