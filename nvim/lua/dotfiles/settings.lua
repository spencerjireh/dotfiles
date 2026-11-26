-- Machine settings recorded by the installer in ~/.config/dotfiles/settings
-- (DOTFILES_KEY=value lines, written from the install profile; see lib/profile.sh).
-- The same file is sourced by zsh and read by tmux. No file means every default.
--
--   DOTFILES_MASON=0     no Mason: language servers come from PATH, no debug adapters
--   DOTFILES_AGENT=kiro  no Claude plugin or keys (default: claude)
--   DOTFILES_GLYPHS=0    the terminal font has no Nerd Font glyphs: plain characters
--   DOTFILES_PREBUILT=0  plugins must not fetch prebuilt binaries (blink.cmp matcher)
local M = {}

local values ---@type table<string, string>|nil

---@return table<string, string> settings keyed without the DOTFILES_ prefix
local function load()
  if values then
    return values
  end
  values = {}
  local dir = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
  local file = io.open(dir .. "/dotfiles/settings", "r")
  if file then
    for line in file:lines() do
      local key, value = line:match("^DOTFILES_([%w_]+)=([%w_-]*)$")
      if key then
        values[key] = value
      end
    end
    file:close()
  end
  return values
end

---@param key string setting name without the DOTFILES_ prefix
---@return string|nil
function M.get(key)
  return load()[key]
end

-- A switch is on unless it is recorded as 0.
---@param key string
---@return boolean
function M.on(key)
  return load()[key] ~= "0"
end

---@return string coding agent this machine uses ("claude" unless recorded otherwise)
function M.agent()
  return load().AGENT or "claude"
end

return M
