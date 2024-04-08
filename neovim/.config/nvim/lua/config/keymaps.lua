-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- NeoTree
map("n", "<C-\\>", "<Cmd>Neotree toggle<CR>")

-- Alt + up/down to copy lines
map("n", "<A-Up>", "<Cmd>move -2<CR>")
map("n", "<A-Down>", "<Cmd>move +<CR>")
