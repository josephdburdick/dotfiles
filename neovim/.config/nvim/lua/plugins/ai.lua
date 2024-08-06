return {
  {
    "robitx/gp.nvim",
    config = function()
      local conf = {
        -- For customization, refer to Install > Configuration in the Documentation/Readme
      }
      require("gp").setup(conf)
    end,
  },
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    opts = function()
      require("neocodeium").setup({
        silent = true,
      })
    end,
  },
  -- use AI to generate code
  {
    "dpayne/CodeGPT.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("codegpt.config")
    end,
  },

  -- Use AI to debug
  {
    "piersolenski/wtf.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
}
