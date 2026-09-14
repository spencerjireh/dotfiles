-- Vesper theme plus every highlight override that keeps other plugins on the same palette
return {
  "datsfilipe/vesper.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("vesper").setup({
      transparent = true,
      italics = {
        comments = true,
        keywords = true,
        functions = true,
        strings = true,
        variables = true,
      },
    })
    vim.cmd.colorscheme("vesper")

    -- Customize which-key to match Vesper theme colors
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#101010" })
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#80d9c7", bg = "#101010" })
    vim.api.nvim_set_hl(0, "WhichKeyTitle", { fg = "#ffc799", bg = "#101010", bold = true })

    -- Customize floating windows (Harpoon, etc.) to match Vesper theme colors
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#101010" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#80d9c7", bg = "#101010" })
    vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#ffc799", bg = "NONE", bold = true })

    -- Subtle cursorline
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1a1a1a" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffc799", bold = true })

    -- Transparent snacks explorer sidebar
    -- Link to Normal (bg=NONE via transparent Vesper) so snacks' default=true won't override
    local hl = vim.api.nvim_set_hl
    hl(0, "SnacksNormal", { link = "Normal" })
    hl(0, "SnacksNormalNC", { link = "Normal" })
    hl(0, "SnacksPicker", { link = "Normal" })
    hl(0, "SnacksPickerBox", { link = "Normal" })
    hl(0, "SnacksPickerList", { link = "Normal" })
    hl(0, "SnacksPickerInput", { link = "Normal" })
    hl(0, "SnacksWinBar", { link = "Normal" })
    hl(0, "SnacksWinBarNC", { link = "Normal" })
    hl(0, "SnacksFooter", { link = "Normal" })
    hl(0, "SnacksTitle", { fg = "#ffc799", bold = true })
    hl(0, "SnacksWinSeparator", { fg = "#505050" })
    hl(0, "SnacksPickerBorder", { fg = "#505050" })
    hl(0, "SnacksPickerBoxBorder", { fg = "#505050" })
    hl(0, "SnacksPickerBoxCursorLine", { bg = "#2a2a2a" })
    hl(0, "SnacksPickerListBorder", { fg = "#505050" })
    hl(0, "SnacksPickerListTitle", { fg = "#ffc799", bold = true })
    hl(0, "SnacksPickerListFooter", { link = "Normal" })
    hl(0, "SnacksPickerListCursorLine", { bg = "#2a2a2a" })
    hl(0, "SnacksPickerInputBorder", { fg = "#505050" })
    hl(0, "SnacksPickerInputFooter", { link = "Normal" })

    -- snacks.words: subtle background for LSP reference matches
    vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#2a2a2a" })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#2a2a2a" })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#2a2a2a" })
  end,
}
