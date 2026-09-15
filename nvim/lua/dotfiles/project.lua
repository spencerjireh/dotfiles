-- Repo-convention helpers shared by conform (plugins/format.lua), nvim-lint
-- (plugins/lint.lua), lualine (plugins/lualine.lua) and the LSP setup.
--
-- Rule for every tool decision: repo config, then repo-local binary, then global
-- binary, then nothing. Neovim never invents a convention a repo does not carry.
local M = {}

---@param source integer|string buffer number or file path (as vim.fs.root)
---@param markers string|string[]
---@return string|nil root directory containing one of the markers
function M.root(source, markers)
  return vim.fs.root(source, markers)
end

-- Small file cache keyed by path and invalidated by mtime, so config lookups
-- that run on every statusline refresh do not hit the disk each time.
local file_cache = {} ---@type table<string, { mtime: integer, text: string }>

---@param path string
---@return string|nil
local function read_cached(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return nil
  end
  local cached = file_cache[path]
  if cached and cached.mtime == stat.mtime.sec then
    return cached.text
  end
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local text = fd:read("*a")
  fd:close()
  file_cache[path] = { mtime = stat.mtime.sec, text = text }
  return text
end

---@param source integer|string buffer number or file path
---@return string|nil path of the nearest pyproject.toml
local function pyproject_path(source)
  local dir = vim.fs.root(source, { "pyproject.toml" })
  return dir and (dir .. "/pyproject.toml") or nil
end

-- True when the nearest pyproject.toml has a `[section]` or `[section.sub]` table.
---@param source integer|string buffer number or file path
---@param section string for example "tool.ruff"
---@return boolean
function M.pyproject_has(source, section)
  local path = pyproject_path(source)
  local text = path and read_cached(path)
  if not text then
    return false
  end
  for line in text:gmatch("[^\n]+") do
    local name = line:match("^%s*%[([%w%.%-_]+)%]")
    if name and (name == section or name:sub(1, #section + 1) == section .. ".") then
      return true
    end
  end
  return false
end

-- Path of the ruff config that applies to the buffer: ruff.toml, .ruff.toml or a
-- pyproject.toml with a [tool.ruff] table. nil when the repo does not use ruff.
---@param bufnr integer
---@return string|nil
function M.ruff_config(bufnr)
  local dir = vim.fs.root(bufnr, { "ruff.toml", ".ruff.toml" })
  if dir then
    local a, b = dir .. "/ruff.toml", dir .. "/.ruff.toml"
    return vim.uv.fs_stat(a) and a or b
  end
  if M.pyproject_has(bufnr, "tool.ruff") then
    return pyproject_path(bufnr)
  end
  return nil
end

-- Formatters for a Python buffer, chosen from the repo's own config:
-- black when [tool.black] exists, ruff when a ruff config exists, nothing otherwise.
-- ruff's import organizer runs only when the config selects the isort rules ("I").
---@param bufnr integer
---@return string[]
function M.python_formatters(bufnr)
  if M.pyproject_has(bufnr, "tool.black") then
    return { "black" }
  end
  local ruff = M.ruff_config(bufnr)
  if not ruff then
    return {}
  end
  local text = read_cached(ruff) or ""
  if text:find("[\"']I%d*[\"']") then
    return { "ruff_organize_imports", "ruff_format" }
  end
  return { "ruff_format" }
end

-- Linters that only make sense inside a repo that configures them. A linter
-- with no entry runs whenever its binary exists.
M.lint_enabled = {
  eslint_d = function(bufnr)
    return vim.fs.root(bufnr, {
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
    }) ~= nil
  end,
  ruff = function(bufnr)
    return M.ruff_config(bufnr) ~= nil
  end,
}

-- nvim-lint linters that apply to the buffer: on PATH and, when gated, configured by the repo.
---@param bufnr integer
---@return string[]
function M.linters(bufnr)
  local ok, lint = pcall(require, "lint")
  if not ok then
    return {}
  end
  local names = lint.linters_by_ft[vim.bo[bufnr].filetype] or {}
  return vim.tbl_filter(function(name)
    if vim.fn.executable(name) ~= 1 then
      return false
    end
    local gate = M.lint_enabled[name]
    return gate == nil or gate(bufnr)
  end, names)
end

-- conform formatters that would run for the buffer (config present, binary found).
---@param bufnr integer
---@return string[]
function M.formatters(bufnr)
  local ok, conform = pcall(require, "conform")
  if not ok then
    return {}
  end
  local infos = conform.list_formatters_to_run(bufnr)
  return vim.tbl_map(function(info)
    return info.name
  end, infos)
end

-- Statusline segment: "lsp:<clients> fmt:<formatters|none> lint:<linters>".
-- Cached per buffer; the augroup below clears it when the answer can change.
local status_cache = {} ---@type table<integer, string>

vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufWritePost", "FileType", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("dotfiles_project_status", { clear = true }),
  callback = function()
    status_cache = {}
  end,
})

---@return string
function M.status()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then
    return ""
  end
  if status_cache[bufnr] then
    return status_cache[bufnr]
  end
  local parts = {}
  local clients = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = bufnr }))
  if #clients > 0 then
    parts[#parts + 1] = "lsp:" .. table.concat(clients, ",")
  end
  local formatters = M.formatters(bufnr)
  parts[#parts + 1] = "fmt:" .. (#formatters > 0 and table.concat(formatters, ",") or "none")
  local linters = M.linters(bufnr)
  if #linters > 0 then
    parts[#parts + 1] = "lint:" .. table.concat(linters, ",")
  end
  status_cache[bufnr] = table.concat(parts, " ")
  return status_cache[bufnr]
end

return M
