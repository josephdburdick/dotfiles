return {
  {
    "OlegGulevskyy/better-ts-errors.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
  -- Quiet down markdownlint: use the shared rule config in the nvim config dir
  -- (.markdownlint.yaml) instead of the all-defaults ruleset.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint.yaml", "-" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
      },
    },
  },
}
