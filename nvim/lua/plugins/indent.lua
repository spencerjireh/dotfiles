-- guess-indent.nvim (shiftwidth/expandtab per buffer from the file's own content).
-- .editorconfig wins when present (override_editorconfig = false); the shiftwidth = 2
-- in init.lua stays the default for new, empty files.
return {
  "NMAC427/guess-indent.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    auto_cmd = true,
    override_editorconfig = false,
    filetype_exclude = { "netrw", "tutor", "markdown" },
    buftype_exclude = { "help", "nofile", "terminal", "prompt" },
  },
}
