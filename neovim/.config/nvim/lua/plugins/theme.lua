-- themes
return {
  -- { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
  -- { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000 },
  -- { "tokyonight.nvim", lazy = false, priority = 1000 },
  -- {
  --   "projekt0n/github-nvim-theme",
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     require("github-theme").setup({
  --       -- ...
  --     })
  --
  --     vim.cmd("colorscheme github_dark")
  --   end,
  -- },
  -- {
  --   -- Theme inspired by Atom
  --   "navarasu/onedark.nvim",
  --   priority = 1000,
  --   opts = {
  --     style = "deep",
  --   },
  --   config = function(_, opts)
  --     opts.style = "deep"
  --     opts.toggle_style_key = "<leader>uI"
  --     require("onedark").setup(opts)
  --   end,
  -- },
  { "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nightfox",
    },
  },
}
