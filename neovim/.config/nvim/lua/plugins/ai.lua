-- AI stack, Cursor-style:
--   Cmd+L / Alt+L  -> Claude Code panel (chat/agent, like Cursor's chat)
--   Cmd+I / Alt+I  -> toggle Claude Code (like Cursor's composer/agent)
--   Cmd+K          -> inline AI edit via CodeCompanion (like Cursor's Cmd+K bar)
-- Cmd (<D-...>) keys work in Neovide and Ghostty (kitty keyboard protocol);
-- Alt (<M-...>) variants are the everywhere-else fallback.
return {
  -- Claude Code: the real CLI in a side panel with native diff accept/deny
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>c", nil, desc = "Claude Code" },
      -- Cursor-style bindings
      { "<D-l>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "t" }, desc = "Claude panel (Cmd+L)" },
      { "<M-l>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "t" }, desc = "Claude panel (Alt+L)" },
      { "<D-l>", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Send selection to Claude (Cmd+L)" },
      { "<M-l>", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Send selection to Claude (Alt+L)" },
      { "<D-i>", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude (Cmd+I)" },
      { "<M-i>", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude (Alt+I)" },
      -- Leader bindings
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>cs",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>cA", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>cD", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },

  -- CodeCompanion: inline edits + chat (Claude if ANTHROPIC_API_KEY, else OpenAI)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    keys = {
      -- ":CodeCompanion " leaves the cmdline open for the instruction, like Cursor's Cmd+K bar
      { "<D-k>", ":CodeCompanion ", mode = { "n", "v" }, silent = false, desc = "Inline AI edit (Cmd+K)" },
      { "<leader>ai", ":CodeCompanion ", mode = { "n", "v" }, silent = false, desc = "Inline AI edit" },
    },
    opts = function()
      local use_anthropic = vim.env.ANTHROPIC_API_KEY ~= nil and vim.env.ANTHROPIC_API_KEY ~= ""
      local primary = use_anthropic and "anthropic" or "openai"

      return {
        strategies = {
          chat = {
            adapter = primary,
            keymaps = {
              close = { modes = { n = "q", i = "<C-c>" } },
              stop = { modes = { n = "<C-s>" } },
              send = { modes = { n = "<CR>", i = "<C-CR>" } },
            },
          },
          inline = {
            adapter = primary,
          },
        },
      }
    end,
  },

  -- Better text object selection for AI context
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
  },
}
