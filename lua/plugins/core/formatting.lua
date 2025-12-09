-- Core Formatting Configuration
-- Replaces LazyVim formatting.lua

return {
  ---------------------------------------------------------------------------
  -- conform.nvim - Formatter plugin
  ---------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
      },
      formatters = {
        injected = { options = { ignore_errors = true } },
      },
    },
    init = function()
      -- Install conform formatter on VeryLazy
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          require("utils.format").register({
            name = "conform.nvim",
            priority = 100,
            primary = true,
            format = function(buf)
              require("conform").format({ bufnr = buf })
            end,
          })
        end,
      })
    end,
  },
}
