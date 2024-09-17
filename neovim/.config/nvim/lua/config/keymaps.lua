-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- escape
map("i", "jk", "<Esc>", { desc = "Escape" })

-- Select all / Copy all
map("n", "<Leader>a", "gg<S-v>G", { desc = "Select all" })
map("n", "<Leader>A", "gg0vG$y", { desc = "Copy all" })

-- Increment/decrement
map("n", "+", "<C-a>", { desc = "Increment" })
map("n", "-", "<C-x>", { desc = "Decrement" })

-- NeoTree
map("n", "<C-\\>", "<Cmd>Neotree toggle<CR>", { silent = true })

-- Control + s to save
map({ "i", "x", "n", "s" }, "<C-s>", "<Cmd>w<CR><Esc>", { desc = "Save file" })
map({ "i", "x", "n", "s" }, "<D-s>", "<Cmd>w<CR><Esc>", { desc = "Save file" })

-- Command + z to undo
map({ "i", "x", "n", "s" }, "<D-z>", "<Cmd>undo<CR><Esc>", { desc = "Undo" })
-- Shift + Command + z to redo
map({ "i", "x", "n", "s" }, "<S-D-z>", "<Cmd>redo<CR><Esc>", { desc = "Redo" })

-- Command + w to close buffer
map({ "i", "x", "n", "s" }, "<D-w>", "<Cmd>bd<CR><Esc>", { desc = "Close buffer" })

-- Copy the current line or selection and paste it above/below
-- directional keys
map("n", "<A-S-Up>", ":t-1<CR>", { silent = true })
map("v", "<A-S-Up>", ":t-1<CR>gv=gv", { silent = true })
map("n", "<A-S-Down>", ":t+1<CR>", { silent = true })
map("v", "<A-S-Down>", ":t'>+<CR>gv=gv", { silent = true })

-- home row keys
map("n", "<A-S-k>", ":t-1<CR>", { silent = true })
map("v", "<A-S-k>", ":t-1<CR>gv=gv", { silent = true })
map("n", "<A-S-j>", ":t+1<CR>", { silent = true })
map("v", "<A-S-j>", ":t'>+<CR>gv=gv", { silent = true })

-- Move lines up / down
-- Ensure these don't conflict with copy operations
-- directional keys
map("n", "<A-Up>", ":m .-2<CR>==", { silent = true })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { silent = true })
map("n", "<A-Down>", ":m .+1<CR>==", { silent = true })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { silent = true })

-- home row keys
map("n", "<A-k>", ":m .-2<CR>==", { silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })
map("n", "<A-j>", ":m .+1<CR>==", { silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })

-- Link to Git repo
map("n", "<Leader>gl", "<Cmd>lua require('ndoo').open()<CR>", { desc = "Open Git link" })
map("v", "<Leader>gl", "<Cmd>lua require('ndoo').open({ v = true })<CR>", { desc = "Open Git link" })

-- Better TS Errors
map({ "n", "v" }, "<Leader>cx", function()
  require("better-ts-errors").toggle()
end, { desc = "Toggle Better TS Error" })

-- Debug with OpenAI
map({ "n", "x" }, "<Leader>cw", "<Cmd>lua require('wtf').ai()<CR>", { desc = "Debug with WTF" })
map("n", "<Leader>cW", "<Cmd>lua require('wtf').search()<CR>", { desc = "Search with WTF" })

-- NeoCodeium
map("i", "<C-A-a>", function()
  require("neocodeium").accept()
end)
map("i", "<C-A-w>", function()
  require("neocodeium").accept_word()
end)
map("i", "<C-A-l>", function()
  require("neocodeium").accept_line()
end)
map("i", "<C-A-e>", function()
  require("neocodeium").cycle_or_complete()
end)
map("i", "<C-A-r>", function()
  require("neocodeium").cycle_or_complete(-1)
end)
map("i", "<C-A-c>", function()
  require("neocodeium").clear()
end)

-- Neovide
if vim.g.neovide == true then
  vim.api.nvim_set_keymap(
    "n",
    "<leader>wf",
    ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>",
    { desc = "Toggle Fullscreen" }
  )
end
