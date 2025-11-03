return {
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = true,
  --   opts = { style = "night", transparent = true },
  -- },
  -- {
  --   "vague2k/vague.nvim",
  --   lazy = false,
  --   priority = 1000,
  -- },
  -- {
  --   "adibhanna/forest-night.nvim",
  --   priority = 1000,
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = { flavor = "mocha", transparent_background = true },
    -- config = function()
    --   require("catppuccin").setup({
    --     vim.cmd.colorscheme("catppuccin"),
    --   })
    -- end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
