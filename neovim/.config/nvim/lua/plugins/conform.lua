return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- Use a sub-list to run only the first available formatter
      javascript = { { "prettier" } },
      typescript = { { "prettier" } },
      typescriptreact = { { "prettier" } },
      css = { { "prettier" } },
    },
  },
  n,
}
