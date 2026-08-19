-- Cursor-style search bindings on top of LazyVim's snacks picker:
--   Cmd+P / Ctrl+P              -> smart file finder (frecency, like Cursor's Cmd+P)
--   Cmd+Shift+P / Ctrl+Shift+P  -> command palette
--   Cmd+Shift+F / Ctrl+Shift+F  -> live grep across the workspace (visual: grep the selection)
--   Cmd+F                       -> fuzzy find in current file
--   Cmd+B                       -> toggle the file explorer sidebar
--   Cmd+T                       -> workspace symbols (Cursor's Cmd+T; needs ghostty's super+t unbind)
--   Cmd+Shift+O / Ctrl+Shift+O  -> symbols in the current file (Cursor's Cmd+Shift+O)
--   F12 / Shift+F12             -> definition / all references of the symbol under cursor
--   gR                          -> references as a persistent Trouble panel, grouped by file
-- Shifted Ctrl combos and Shift+F12 need a terminal with the kitty keyboard
-- protocol (Ghostty has it; tmux passes it with extended-keys on).
--
-- LazyVim's own gr / gd / <leader>ss / <leader>sS keep working; these are the
-- Cursor-muscle-memory aliases for the same pickers.

-- A terminal cell is roughly twice as tall as it is wide, so the screen is
-- portrait-ish when columns < lines * 2. Fullscreen landscape is ~3.7x,
-- fullscreen portrait ~1.2x, so the boundary is not delicate.
local function portrait()
  return vim.o.columns < vim.o.lines * 2
end

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
      { "<D-S-f>", function() Snacks.picker.grep_word() end, mode = "x", desc = "Grep selection (Cmd+Shift+F)" },
      { "<C-S-f>", function() Snacks.picker.grep_word() end, mode = "x", desc = "Grep selection (Ctrl+Shift+F)" },
      { "<D-f>", function() Snacks.picker.lines() end, desc = "Find in file (Cmd+F)" },
      { "<D-b>", function() Snacks.explorer() end, desc = "Toggle explorer (Cmd+B)" },
      -- Symbol search. LSP-backed, so an "instance" is a semantic reference,
      -- not a text match — renamed imports and shadowed names resolve correctly.
      { "<D-t>", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols (Cmd+T)" },
      { "<D-S-o>", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols (Cmd+Shift+O)" },
      { "<C-S-o>", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols (Ctrl+Shift+O)" },
      { "<F12>", function() Snacks.picker.lsp_definitions() end, desc = "Go to definition (F12)" },
      { "<S-F12>", function() Snacks.picker.lsp_references() end, desc = "All references (Shift+F12)" },
    },
    opts = {
      picker = {
        layout = {
          -- Snacks decides its layout by width alone (>= 120 cols -> preview
          -- beside the list), which turns a fullscreen portrait terminal into
          -- two cramped half-width panes. Pick by orientation instead; the
          -- preset resolves on every picker open, so dragging the terminal to
          -- another monitor just works.
          preset = function()
            if portrait() then
              return "portrait"
            end
            return vim.o.columns >= 120 and "default" or "vertical"
          end,
        },
        layouts = {
          -- The built-in "vertical" preset at half width is wasteful on a
          -- narrow screen. This is that preset stretched to nearly the full
          -- terminal, with the preview given half the height so the code
          -- under the cursor line is actually readable.
          portrait = {
            layout = {
              backdrop = false,
              width = 0.95,
              min_width = 60,
              height = 0.95,
              border = "rounded",
              box = "vertical",
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", height = 0.5, border = "top" },
            },
          },
        },
      },
    },
  },

  -- References as a persistent, file-grouped panel — the closest analog to
  -- Cursor's "Find All References" pane (the picker closes on jump; this
  -- stays open while you walk the instances). LazyVim docks Trouble's lsp
  -- mode on the right, which is the wrong axis on a portrait monitor, so
  -- dock it at the bottom there. Decided once, when Trouble first loads.
  {
    "folke/trouble.nvim",
    optional = true,
    opts = function(_, opts)
      if portrait() then
        opts.modes = vim.tbl_deep_extend("force", opts.modes or {}, {
          lsp = { win = { position = "bottom" } },
        })
      end
    end,
    keys = {
      { "gR", "<cmd>Trouble lsp_references toggle focus=true<cr>", desc = "References (Trouble)" },
    },
  },
}
