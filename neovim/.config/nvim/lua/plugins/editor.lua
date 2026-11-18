return {
  {
    "sQVe/sort.nvim",
    lazy = false,
  },

  {
    "mg979/vim-visual-multi",
    lazy = false,
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",

    ---@type Flash.Config
    opts = {
      modes = {
        -- Show jump labels on the current line when using f/t/F/T
        char = {
          jump_labels = true,
        },
      },
    },
    -- stylua: ignore
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash"
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter"
      },
      {
        "r",
        mode = "o",
        function() require("flash").remote() end,
        desc = "Remote Flash"
      },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search"
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search"
      },
    },
  },
  -- Update imports when renaming files from the explorer
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = { "nvim-lua/plenary.nvim" },

    event = { "BufRead", "BufWinEnter", "BufNewFile" },
    opts = {},
  },

  -- Precognition previews motion targets (b e w $ …) on a virtual line
  {
    "tris203/precognition.nvim",
    event = "BufRead",
    opts = {
      startVisible = true,
      highlightColor = {
        fg = "#666666",
      },
      -- v1.3.0 turned these on by default; they flood the virtual line with
      -- f/t target letters and drown out the classic motion preview
      targetedMotionHints = {
        enabled = false,
      },
    },
    keys = {
      {
        "<leader>up",
        function() require("precognition").toggle() end,
        desc = "Toggle motion hints (Precognition)",
      },
    },
  },

  -- Prevent signature window from fighting completion; use glK / blink when needed
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        signature = {
          auto_open = {
            enabled = false,
          },
        },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-jest" },
    opts = { adapters = { "neotest-jest" } },
  },

  {
    "catgoose/nvim-colorizer.lua",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        names = true,
        RRGGBBAA = true,
        css = true,
        tailwind = true,
        mode = "background",
      },
    },
  },

  -- code actions with preview (snacks backend; telescope is no longer installed)
  {
    "aznhe21/actions-preview.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      backend = { "snacks", "nui" },
    },
  },
}
