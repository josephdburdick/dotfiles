return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "famiu/bufdelete.nvim", -- for autocmd
      {
        "echasnovski/mini.visits", -- oldfiles alternative
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            -- '.git',
            ".DS_Store",
            "thumbs.db",
          },
          never_show = {},
        },
      },
    },
  },
  {
    "mg979/vim-visual-multi",
    lazy = false,
  },
}
