return {
  -- sorting
  {
    "sQVe/sort.nvim",
    lazy = false,
  },

  {
    "mg979/vim-visual-multi",
    lazy = false,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",

    ---@type Flash.Config
    opts = {
      enable = true,
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" },
        function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" },
        function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o",
        function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" },
        function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },
        function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  -- Github link integration
  {
    "mistweaverco/ndoo.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    lazy = false,
  },

  --
  --
  -- Update imports when renaming files in nvim-tree
  -- https://github.com/antosha417/nvim-lsp-file-operations
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },

    event = { "BufRead", "BufWinEnter", "BufNewFile" },

    -- cmd = { "NvimTreeToggle", "NvimTreeFocus" },

    config = function()
      require("lsp-file-operations").setup()
    end,
  },

  -- Precognition shows key hints in gutter
  {
    "tris203/precognition.nvim",
    event = "BufRead",
    config = {
      highlightColor = {
        fg = "#666666",
      },
    },
  },

  -- Prevent warning messages inline; use Shift K instead   {
  "folke/noice.nvim",
  opts = {
    lsp = {
      signature = { auto_open = {
        enabled = false,
      } },
    },
  },

  -- tests
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-jest",
      "zidhuss/neotest-minitest",
    },

    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest"),
        },
      })
    end,
  },

  -- Github link integration
  {
    "mistweaverco/ndoo.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },

  -- Colorize codes
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = false, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = "background", -- Set the display mode.
        -- Available methods are false / true / "normal" / "lsp" / "both"
        -- True is same as normal
        tailwind = true, -- Enable tailwind colors
        -- parsers can contain values used in |user_default_options|
        sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
        virtualtext = "■",
        -- update color values even if buffer is not focused
        -- example use: cmp_menu, cmp_docs
        always_update = false,
      },
      -- all the sub-options of filetypes apply to buftypes
      buftypes = {},
    },
  },
  -- Add Tailwind context window for definitions
  {
    "luckasRanarison/tailwind-tools.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {}, -- your configuration
  },
  -- code actions
  {
    "rachartier/tiny-code-action.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    event = "LspAttach",
    config = function()
      require("tiny-code-action").setup()
    end,
  },
  -- allow TAB for code completion and snippets
  -- {
  --   "hrsh7th/nvim-cmp",
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     local has_words_before = function()
  --       unpack = unpack or table.unpack
  --       local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  --       return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  --     end
  --
  --     local cmp = require("cmp")
  --
  --     opts.mapping = vim.tbl_extend("force", opts.mapping, {
  --       ["<Tab>"] = cmp.mapping(function(fallback)
  --         if cmp.visible() then
  --           -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
  --           -- cmp.select_next_item()
  --           cmp.confirm({ select = true })
  --         elseif vim.snippet.active({ direction = 1 }) then
  --           vim.schedule(function()
  --             vim.snippet.jump(1)
  --           end)
  --         elseif has_words_before() then
  --           cmp.complete()
  --         else
  --           fallback()
  --         end
  --       end, { "i", "s" }),
  --       ["<S-Tab>"] = cmp.mapping(function(fallback)
  --         if cmp.visible() then
  --           cmp.select_prev_item()
  --         elseif vim.snippet.active({ direction = -1 }) then
  --           vim.schedule(function()
  --             vim.snippet.jump(-1)
  --           end)
  --         else
  --           fallback()
  --         end
  --       end, { "i", "s" }),
  --     })
  --   end,
  -- },
}
