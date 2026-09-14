-- auto-save.nvim (keep disk in sync with buffer edits)
return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    enabled = true,
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost" },
      defer_save = { "InsertLeave", "TextChanged" },
    },
    condition = function(buf)
      local buftype = vim.bo[buf].buftype
      if buftype ~= "" then
        return false
      end
      if vim.bo[buf].readonly or not vim.bo[buf].modifiable then
        return false
      end
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname == "" then
        return false
      end
      local ok, stats = pcall(vim.uv.fs_stat, bufname)
      if ok and stats and stats.size > 1024 * 1024 then
        return false
      end
      return true
    end,
    write_all_buffers = false,
    noautocmd = false,
    debounce_delay = 1000,
  },
}
