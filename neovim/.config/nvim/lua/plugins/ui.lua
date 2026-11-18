return {
  {
    "adelarsq/image_preview.nvim",
    event = "VeryLazy",
    config = function()
      require("image_preview").setup()
    end,
  },
  {
    "karb94/neoscroll.nvim",
    config = function()
      local neoscroll = require("neoscroll")

      neoscroll.setup({
        hide_cursor = false,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing = "quadratic",
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
  { "sphamba/smear-cursor.nvim" },
  -- Colored marks in scrollbar (colors from the active nightfox palette).
  -- Loads the variant that is actually set rather than a hardcoded one, so
  -- switching carbonfox/duskfox/etc. in theme.lua carries the marks along.
  -- A non-nightfox scheme just fails the pcall and falls back to defaults.
  {
    "petertriho/nvim-scrollbar",
    -- v2 rejects the handle/marks options below; migrate before unpinning.
    -- https://github.com/petertriho/nvim-scrollbar/issues/121
    branch = "v1",
    config = function()
      local ok, palette = pcall(function()
        return require("nightfox.palette").load(vim.g.colors_name)
      end)
      local opts = {}
      if ok and palette then
        opts = {
          handle = {
            color = palette.bg2,
          },
          marks = {
            Search = { color = palette.orange.base },
            Error = { color = palette.red.base },
            Warn = { color = palette.yellow.base },
            Info = { color = palette.blue.base },
            Hint = { color = palette.cyan.base },
            Misc = { color = palette.magenta.base },
          },
        }
      end
      require("scrollbar").setup(opts)
    end,
  },
}
