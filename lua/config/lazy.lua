-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load options before plugins (for mapleader etc.)
require("config.options")

require("lazy").setup({
  spec = {
    ---------------------------------------------------------------------------
    -- Core Plugins (replaces LazyVim base)
    ---------------------------------------------------------------------------
    { import = "plugins.core.ui" },
    { import = "plugins.core.editor" },
    { import = "plugins.core.coding" },
    { import = "plugins.core.treesitter" },
    { import = "plugins.core.lsp" },
    { import = "plugins.core.formatting" },
    { import = "plugins.core.linting" },
    
    ---------------------------------------------------------------------------
    -- Completion (Blink.cmp)
    ---------------------------------------------------------------------------
    { import = "plugins.coding.blink" },
    
    ---------------------------------------------------------------------------
    -- Picker (Snacks picker)
    ---------------------------------------------------------------------------
    { import = "plugins.editor.snacks-picker" },
    
    ---------------------------------------------------------------------------
    -- Editor Extras
    ---------------------------------------------------------------------------
    { import = "plugins.editor.aerial" },
    { import = "plugins.editor.mini-files" },
    { import = "plugins.editor.refactoring" },
    
    ---------------------------------------------------------------------------
    -- Coding Extras
    ---------------------------------------------------------------------------
    { import = "plugins.coding.mini-surround" },
    { import = "plugins.coding.yanky" },
    
    ---------------------------------------------------------------------------
    -- DAP (Debugging)
    ---------------------------------------------------------------------------
    { import = "plugins.dap" },
    
    ---------------------------------------------------------------------------
    -- Testing
    ---------------------------------------------------------------------------
    { import = "plugins.test" },
    
    ---------------------------------------------------------------------------
    -- AI (Sidekick + Copilot)
    ---------------------------------------------------------------------------
    { import = "plugins.ai.sidekick" },
    
    ---------------------------------------------------------------------------
    -- Language Support
    ---------------------------------------------------------------------------
    { import = "plugins.lang.go" },
    { import = "plugins.lang.typescript" },
    { import = "plugins.lang.nix" },
    { import = "plugins.lang.docker" },
    { import = "plugins.lang.json" },
    { import = "plugins.lang.yaml" },
    { import = "plugins.lang.markdown" },
    { import = "plugins.lang.terraform" },
    { import = "plugins.lang.sql" },
    { import = "plugins.lang.toml" },
    { import = "plugins.lang.nushell" },
    
    ---------------------------------------------------------------------------
    -- Colorscheme
    ---------------------------------------------------------------------------
    { import = "plugins.colorscheme" },
    
    ---------------------------------------------------------------------------
    -- Custom plugins (from your existing config)
    ---------------------------------------------------------------------------
    { import = "plugins.dashboard" },
    { import = "plugins.oil" },
    { import = "plugins.multicursor" },
    { import = "plugins.kulala" },
    { import = "plugins.codesnap" },
    { import = "plugins.buf" },
    { import = "plugins.vscode-diff" },
    { import = "plugins.java" },
    { import = "plugins.kdl" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load keymaps and autocmds after lazy
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("config.keymaps")
    require("config.autocmds")
  end,
})
