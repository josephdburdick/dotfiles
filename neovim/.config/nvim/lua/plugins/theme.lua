-- themes
return {
  { "ellisonleao/gruvbox.nvim" },
  { "tokyonight.nvim" },
  {
    -- Theme inspired by Atom
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = {
      style = "deep",
    },
    config = function(_, opts)
      opts.style = "deep"
      opts.toggle_style_key = "<leader>uI"
      require("onedark").setup(opts)
    end,
  }, -- Configure Lazyvim to load theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
