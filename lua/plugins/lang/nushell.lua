-- Nushell language support
-- Replaces lazyvim.plugins.extras.lang.nushell + your custom nushell.lua

return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "nu" } },
  },

  -- LSP (nushell has built-in LSP)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nushell = {},
      },
    },
  },

  -- Formatting (from your custom config - topiary)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nu = { "topiary_nu" },
      },
      formatters = {
        topiary_nu = {
          command = "topiary",
          args = { "format", "--language", "nickel", "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
}
