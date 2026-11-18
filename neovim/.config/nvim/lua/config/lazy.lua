local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.test.core" },
    { import = "lazyvim.plugins.extras.coding.yanky" },
    { import = "lazyvim.plugins.extras.util.project" },
    { import = "plugins" },
  },
  ui = {
    border = "single",
  },
  defaults = {
    -- Custom plugins load at startup unless their spec says otherwise.
    lazy = false,
    -- Many plugins have stale semver tags; track the latest commit instead.
    version = false,
  },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarplugin",
        "tohtml",
        "tutor",
        "zipplugin",
      },
    },
  },
})
