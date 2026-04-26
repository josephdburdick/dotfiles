-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local ok, wk = pcall(require, "which-key")
    if not ok then
      return
    end
    wk.add({
      { "<leader>a", group = "AI" },
      { "<leader>v", group = "scope (prompts)" },
    })
  end,
})
