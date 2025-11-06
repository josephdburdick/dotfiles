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

-- NeoCodeium (AI Code Completion)
map("i", "<Tab>", function()
  require("neocodeium").accept()
end, { desc = "Accept AI suggestion" })
map("i", "<S-Tab>", function()
  require("neocodeium").cycle_or_complete(-1)
end, { desc = "Previous AI suggestion" })

-- Keep alternative keybindings for when TAB is not available
map("i", "<C-A-a>", function()
  require("neocodeium").accept()
end, { desc = "Accept AI suggestion (alternative)" })
map("i", "<C-A-w>", function()
  require("neocodeium").accept_word()
end, { desc = "Accept AI word" })
map("i", "<C-A-l>", function()
  require("neocodeium").accept_line()
end, { desc = "Accept AI line" })
map("i", "<C-A-e>", function()
  require("neocodeium").cycle_or_complete()
end, { desc = "Cycle AI suggestions" })
map("i", "<C-A-r>", function()
  require("neocodeium").cycle_or_complete(-1)
end, { desc = "Previous AI suggestion (alternative)" })
map("i", "<C-A-c>", function()
  require("neocodeium").clear()
end, { desc = "Clear AI suggestions" })

-- AI Assistant Keybindings

-- CodeCompanion - AI Chat Interface
map({ "n", "v" }, "<Leader>ac", function()
  vim.cmd("CodeCompanionChat")
end, { desc = "Open AI Chat (CodeCompanion)" })

map({ "n", "v" }, "<Leader>ai", function()
  vim.cmd("CodeCompanionActions")
end, { desc = "AI Actions (CodeCompanion)" })

-- Avante - Advanced AI Assistant
map({ "n", "v" }, "<Leader>aa", function()
  require("avante.api").ask()
end, { desc = "Ask AI (Avante)" })

map({ "n", "v" }, "<Leader>ae", function()
  require("avante.api").edit()
end, { desc = "Edit with AI (Avante)" })

map({ "n", "v" }, "<Leader>ar", function()
  require("avante.api").refresh()
end, { desc = "Refresh AI suggestions (Avante)" })

-- GP.nvim - GPT-based assistance
map({ "n", "v" }, "<Leader>gp", "<Cmd>GpChatNew popup<CR>", { desc = "GPT Chat (popup)" })
map({ "n", "v" }, "<Leader>gP", "<Cmd>GpChatNew split<CR>", { desc = "GPT Chat (split)" })
map({ "n", "v" }, "<Leader>gc", "<Cmd>GpChatToggle popup<CR>", { desc = "Toggle GPT Chat" })

-- Text selection for AI context (mini.ai)
map({ "n", "v" }, "<Leader>ao", "vao", { desc = "Select outer block for AI", remap = true })
map({ "n", "v" }, "<Leader>ai", "vai", { desc = "Select inner block for AI", remap = true })
map({ "n", "v" }, "<Leader>af", "vaf", { desc = "Select outer function for AI", remap = true })
map({ "n", "v" }, "<Leader>aF", "vif", { desc = "Select inner function for AI", remap = true })
map({ "n", "v" }, "<Leader>ac", "vac", { desc = "Select outer class for AI", remap = true })
map({ "n", "v" }, "<Leader>aC", "vic", { desc = "Select inner class for AI", remap = true })

-- Quick AI prompts for common tasks
map({ "n", "v" }, "<Leader>ad", function()
  vim.cmd("CodeCompanionChat /document")
end, { desc = "Document code with AI" })

map({ "n", "v" }, "<Leader>at", function()
  vim.cmd("CodeCompanionChat /test")
end, { desc = "Generate tests with AI" })

map({ "n", "v" }, "<Leader>ax", function()
  vim.cmd("CodeCompanionChat /explain")
end, { desc = "Explain code with AI" })

-- Neovide
if vim.g.neovide == true then
  vim.api.nvim_set_keymap(
    "n",
    "<leader>wf",
    ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>",
    { desc = "Toggle Fullscreen" }
  )
end
