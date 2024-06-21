-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- escape
map("i", "jk", "<Esc>", { desc = "Escape" })

-- Select all
map("n", "<Leader>a", "gg0vG$", { desc = "Select all" })
map("n", "<Leader>A", "gg0vG$y", { desc = "Copy all" })

-- NeoTree
map("n", "<C-\\>", "<Cmd>Neotree toggle<CR>")

-- Control + s to save
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Command + s to save
map({ "i", "x", "n", "s" }, "<D-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Copy the current line or selection and paste it above/below
map("n", "<A-S-Up>", ":t-1<CR>", { silent = true })
map("n", "<A-S-Down>", ":t+1<CR>", { silent = true })
map("v", "<A-S-Up>", ":t-1<CR>gv=gv", { silent = true })
map("v", "<A-S-Down>", ":t'>+<CR>gv=gv", { silent = true })

-- Move lines up / down
-- Ensure these don't conflict with copy operations
map("n", "<A-Up>", ":m .-2<CR>==", { silent = true })
map("n", "<A-Down>", ":m .+1<CR>==", { silent = true })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { silent = true })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { silent = true })
