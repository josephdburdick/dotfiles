return {
  -- image preview
  {
    "adelarsq/image_preview.nvim",
    event = "VeryLazy",
    config = function()
      require("image_preview").setup()
    end,
  },
  -- neo tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        window = {
          mappings = {
            ["<leader>i"] = "image_wezterm",
          },
        },
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            -- '.git',
            ".DS_Store",
            "thumbs.db",
          },
          never_show = {},
        },
      },
      commands = {
        image_wezterm = function(state)
          local node = state.tree:get_node()
          if node.type == "file" then
            require("image_preview").PreviewImage(node.path)
          end
        end,
      },
    },
  },
  -- smooth scrolling
  {
    "karb94/neoscroll.nvim",
    config = function()
      local neoscroll = require("neoscroll")
      neoscroll.setup({
        -- Default easing function used in any animation where
        -- the `easing` argument has not been explicitly supplied
        hide_cursor = false, -- Hide cursor while scrolling
        stop_eof = true, -- Stop at <EOF> when scrolling downwards
        respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing = "quadratic", -- Default easing function
        pre_hook = nil, -- Function to run before the scrolling animation starts
        post_hook = nil, -- Function to run after the scrolling animation ends
        performance_mode = false, -- Disable "Performance Mode" on all buffers.
      })
      local keymap = {
        ["<C-u>"] = function()
          neoscroll.ctrl_u({ duration = 150 })
        end,
        ["<C-d>"] = function()
          neoscroll.ctrl_d({ duration = 150 })
        end,
        ["<C-b>"] = function()
          neoscroll.ctrl_b({ duration = 250 })
        end,
        ["<C-f>"] = function()
          neoscroll.ctrl_f({ duration = 250 })
        end,
        ["<C-y>"] = function()
          neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 })
        end,
        ["<C-e>"] = function()
          neoscroll.scroll(0.1, { move_cursor = false, duration = 100 })
        end,
        ["zt"] = function()
          neoscroll.zt({ half_win_duration = 150 })
        end,
        ["zz"] = function()
          neoscroll.zz({ half_win_duration = 150 })
        end,
        ["zb"] = function()
          neoscroll.zb({ half_win_duration = 150 })
        end,
      }
      local modes = { "n", "v", "x" }
      for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
      end
    end,
  },
  -- Colored marks in scrollbar
  {
    "petertriho/nvim-scrollbar",
    config = function()
      local colors = require("tokyonight.colors").setup()

      require("scrollbar").setup({
        handle = {
          color = colors.bg_highlight,
        },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
          Misc = { color = colors.purple },
        },
      })
    end,
  },
}
