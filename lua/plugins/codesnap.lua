return {
  {
    "mistricky/codesnap.nvim",
    build = "make",
    init = function()
      require("which-key").add({
        { "<leader>cx", ":CodeSnap<CR>", desc = "CodeSnap", mode = "v" },
      })
    end,

    config = function()
      require("codesnap").setup({
        has_breadcrumbs = true,
        bg_theme = "grape",
        code_font_family = "Iosevka Nerd Font Mono",
        watermark = "",
      })
    end,
  },
}
