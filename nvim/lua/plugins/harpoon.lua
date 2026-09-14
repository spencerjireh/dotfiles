-- Harpoon (quick file marks under <leader>h)
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup({
      settings = {
        save_on_toggle = false,
        sync_on_ui_close = true,
        key = function()
          return vim.uv.cwd()
        end,
      },
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
    })

    -- Keymaps using <leader>h prefix
    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "Add file to Harpoon" })

    vim.keymap.set("n", "<leader>hh", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Open Harpoon menu" })

    -- Quick jump to marks 1-5 (<leader>h1 .. <leader>h5)
    for i = 1, 5 do
      vim.keymap.set("n", "<leader>h" .. i, function()
        harpoon:list():select(i)
      end, { desc = "Jump to Harpoon mark " .. i })
    end

    -- Navigate between marks
    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end, { desc = "Next Harpoon mark" })

    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev()
    end, { desc = "Previous Harpoon mark" })
  end,
}
