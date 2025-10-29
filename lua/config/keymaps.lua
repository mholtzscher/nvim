-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Oil file manager
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open Oil file manager" })
