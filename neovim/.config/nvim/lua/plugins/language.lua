return {
  -- -- Replacement for tsserver lsp config
  -- -- https://github.com/pmizio/typescript-tools.nvim
  -- {
  --   "pmizio/typescript-tools.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  --   ft = {
  --     "javascript",
  --     "typescript",
  --     "javascriptreact",
  --     "typescriptreact",
  --   },
  -- },
  --
  {
    "OlegGulevskyy/better-ts-errors.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = {
      keymaps = {
        toggle = "<leader>cD", -- default '<leader>dd'
        go_to_definition = "<leader>cX", -- default '<leader>dx'
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
  },
}
