return {
  -- Configure snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      {
        "<leader>fp",
        function()
          Snacks.picker.projects({
            dev = { "~/code" },
            -- patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "package.json", "Makefile" },
            max_depth = 3,
            -- win = { input = { keys = { ["<cr>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } } } } },
          })
        end,
        desc = "Projects",
      },
    },
    opts = {},
  },
}
