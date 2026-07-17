-- Cursor-style search bindings on top of LazyVim's snacks picker:
--   Cmd+P / Ctrl+P              -> smart file finder (frecency, like Cursor's Cmd+P)
--   Cmd+Shift+P / Ctrl+Shift+P  -> command palette
--   Cmd+Shift+F / Ctrl+Shift+F  -> live grep across the workspace
--   Cmd+F                       -> fuzzy find in current file
--   Cmd+B                       -> toggle the file explorer sidebar
-- Shifted Ctrl combos need a terminal with the kitty keyboard protocol (Ghostty has it).
return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<D-p>", function() Snacks.picker.smart() end, desc = "Find files (Cmd+P)" },
      { "<C-p>", function() Snacks.picker.smart() end, desc = "Find files (Ctrl+P)" },
      { "<D-S-p>", function() Snacks.picker.commands() end, desc = "Command palette (Cmd+Shift+P)" },
      { "<C-S-p>", function() Snacks.picker.commands() end, desc = "Command palette (Ctrl+Shift+P)" },
      { "<D-S-f>", function() Snacks.picker.grep() end, desc = "Grep workspace (Cmd+Shift+F)" },
      { "<C-S-f>", function() Snacks.picker.grep() end, desc = "Grep workspace (Ctrl+Shift+F)" },
      { "<D-f>", function() Snacks.picker.lines() end, desc = "Find in file (Cmd+F)" },
      { "<D-b>", function() Snacks.explorer() end, desc = "Toggle explorer (Cmd+B)" },
    },
  },
}
