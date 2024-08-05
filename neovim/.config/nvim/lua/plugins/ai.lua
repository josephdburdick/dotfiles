return {
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
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
