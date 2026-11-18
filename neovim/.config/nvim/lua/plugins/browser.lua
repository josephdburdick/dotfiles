-- Browser-style chrome: buffers as slanted tabs along the top, and a
-- breadcrumb "address bar" (path › symbol) under them.
--   Alt+1…8 / Cmd+1…8  -> jump to tab N;  Alt+9 / Cmd+9 -> last tab (as in Chrome)
--   Alt+Shift+[ / ]    -> previous / next tab (Shift+H / Shift+L still work)
--   <leader>bd / Cmd+W -> close tab;  middle-click a tab closes it too
--   <leader>;          -> pick a breadcrumb segment
-- Ghostty keeps Cmd+digit and Cmd+W for its own tabs, so those only land in Neovide.

local function goto_tab(n)
  return function()
    require("bufferline").go_to(n, true)
  end
end

local tab_keys = {}
for i = 1, 9 do
  local target = i == 9 and -1 or i
  local desc = i == 9 and "Go to last tab" or ("Go to tab " .. i)
  table.insert(tab_keys, { "<M-" .. i .. ">", goto_tab(target), desc = desc })
  table.insert(tab_keys, { "<D-" .. i .. ">", goto_tab(target), desc = desc })
end
vim.list_extend(tab_keys, {
  { "<M-{>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous tab" },
  { "<M-}>", "<cmd>BufferLineCycleNext<cr>", desc = "Next tab" },
})

return {
  {
    "akinsho/bufferline.nvim",
    init = function()
      -- Required for hover-to-reveal close buttons.
      vim.o.mousemoveevent = true
    end,
    keys = tab_keys,
    opts = {
      options = {
        mode = "buffers",
        always_show_bufferline = true,
        separator_style = "slant",
        indicator = { style = "none" },
        show_buffer_close_icons = true,
        show_close_icon = false,
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        middle_mouse_command = function(n)
          Snacks.bufdelete(n)
        end,
        tab_size = 20,
        max_name_length = 24,
        truncate_names = true,
        hover = { enabled = true, delay = 120, reveal = { "close" } },
      },
    },
  },

  {
    "Bekaboo/dropbar.nvim",
    event = "LazyFile",
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Pick breadcrumb",
      },
    },
    init = function()
      -- dropbar shows the symbol path; drop LazyVim's duplicate in the statusline.
      vim.g.trouble_lualine = false
    end,
    opts = {},
  },
}
