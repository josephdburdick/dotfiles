return {
  -- sorting
  {
    "sQVe/sort.nvim",
    lazy = false,
  },
  --  Disable default tab
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
            cmp.select_next_item()
          -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
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

  -- Replacement for tsserver lsp config
  -- https://github.com/pmizio/typescript-tools.nvim
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
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
}
