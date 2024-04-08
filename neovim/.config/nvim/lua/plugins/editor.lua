return {
  -- commenting; remove when native to neovim
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },

  {
    "dinhhuy258/git.nvim",
    event = "BufReadPre",
    opts = {
      keymaps = {
        -- Open blame window
        blame = "<Leader>gb",
        -- Open file/folder in git repository
        browse = "<Leader>go",
      },
    },
  },

  { "echasnovski/mini.nvim", version = "*" },
}
