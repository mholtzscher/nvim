-- Nix language support
-- Replaces lazyvim.plugins.extras.lang.nix

return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "nix" } },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nixfmt" },
              },
            },
          },
        },
      },
    },
  },

  -- Formatting (nixfmt not via Mason, needs to be installed on system)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt" },
      },
    },
  },

  -- Linting (statix not via Mason, needs to be installed on system)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        nix = { "statix" },
      },
    },
  },

  -- Mason (nil_ls only - nixfmt/statix should come from Nix)
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- nil_ls can be installed via mason or nix
        -- "nil", -- Uncomment if you want Mason to manage nil
      },
    },
  },
}
