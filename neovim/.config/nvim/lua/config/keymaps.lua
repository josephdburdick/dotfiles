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

-- Snacks explorer
map("n", "<C-\\>", function()
  require("snacks").explorer()
end, { silent = true, desc = "Explorer (Snacks)" })

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

-- Copilot inline suggestions: Tab accepts via LazyVim/blink (ai_accept); M-] / M-[ cycle Copilot

-- AI Assistant Keybindings

-- CodeCompanion - AI Chat Interface (Claude if ANTHROPIC_API_KEY else OpenAI — see lua/plugins/ai.lua)
map({ "n", "v" }, "<Leader>ac", function()
  vim.cmd("CodeCompanionChat")
end, { desc = "AI chat (CodeCompanion)" })

map({ "n", "v" }, "<Leader>ay", function()
  vim.cmd("CodeCompanionActions")
end, { desc = "AI actions palette (CodeCompanion)" })

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

-- Treesitter scope selection for prompts / CodeCompanion context (mini.ai; leader a = AI only)
map({ "n", "v" }, "<Leader>vo", "vao", { desc = "Select outer block (scope)", remap = true })
map({ "n", "v" }, "<Leader>vi", "vai", { desc = "Select inner block (scope)", remap = true })
map({ "n", "v" }, "<Leader>vf", "vaf", { desc = "Select outer function (scope)", remap = true })
map({ "n", "v" }, "<Leader>vF", "vif", { desc = "Select inner function (scope)", remap = true })
map({ "n", "v" }, "<Leader>vc", "vac", { desc = "Select outer class (scope)", remap = true })
map({ "n", "v" }, "<Leader>vC", "vic", { desc = "Select inner class (scope)", remap = true })

-- Quick AI prompts for common tasks
map({ "n", "v" }, "<Leader>ad", function()
  vim.cmd("CodeCompanionChat /document")
end, { desc = "Document code with AI" })

map({ "n", "v" }, "<Leader>aT", function()
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
