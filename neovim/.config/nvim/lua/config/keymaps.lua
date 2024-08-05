-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- escape
map("i", "jk", "<Esc>", { desc = "Escape" })

-- Select all / Copy all
map("n", "<Leader>a", "gg<S-v>G", { desc = "Select all" })
map("n", "<Leader>A", "gg0vG$y", { desc = "Copy all" })
-- map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })
-- map("n", "<C-A>", "gg<S-v>Gy", { desc = "Copy all" })

-- Increment/decrement
map("n", "+", "<C-a>", { desc = "Increment" })
map("n", "-", "<C-x>", { desc = "Decrement" })

-- NeoTree
map("n", "<C-\\>", "<Cmd>Neotree toggle<CR>", { silent = true })

-- Control + s to save
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Command + s to save
map({ "i", "x", "n", "s" }, "<D-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

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

-- Code Action
map("n", "<leader>ca", function()
  require("tiny-code-action").code_action()
end, { desc = "(tiny) Code action", noremap = true, silent = true })

-- Better TS Errors
map(
  { "n", "v" },
  "<Leader>cx",
  "<Cmd>lua require('better-ts-errors').toggle()<CR>",
  { desc = "Toggle Better TS Error" }
)
map(
  { "n", "v" },
  "<Leader>cX",
  "<Cmd>lua require('better-ts-errors').go_to_definition()<CR>",
  { desc = "Toggle Better TS Definition" }
)
-- Debug with OpenAI
map({ "n", "x" }, "<Leader>cw", "<Cmd>lua require('wtf').ai()<CR>", { desc = "Debug with WTF" })
map("n", "<Leader>cW", "<Cmd>lua require('wtf').search()<CR>", { desc = "Search with WTF" })

-- Obsidian
-- map("n", "<leader>Od", "<cmd>ObsidianToday<CR>", { desc = "Obsidian: Open today's daily note" })
-- map("n", "<leader>Oo", "<cmd>ObsidianOpen<CR>", { desc = "Obsidian: Open in Obsidian" })
-- map("n", "<leader>On", "<cmd>ObsidianNew<CR>", { desc = "Obsidian: Open New Note" })
-- map("n", "<leader>Ofp", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Obsidian: Search Files" })
-- map("n", "<leader>Ofa", "<cmd>ObsidianSearch<CR>", { desc = "Obsidian: Search In Files" })

-- Codeium
map("i", "<C-A-Tab>", function()
  return vim.api.nvim_input(vim.fn["codeium#Accept"]())
end, { expr = true, silent = true })
map("i", "<C-A-]>", function()
  return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true, silent = true })
map("i", "<C-A-[>", function()
  return vim.fn["codeium#CycleCompletions"](-1)
end, { expr = true, silent = true })
map("i", "<c-x>", function()
  return vim.fn["codeium#Clear"]()
end, { expr = true, silent = true })

-- Neovide
if vim.g.neovide == true then
  vim.api.nvim_set_keymap(
    "n",
    "<leader>wf",
    ":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>",
    { desc = "Toggle Fullscreen" }
  )
end
