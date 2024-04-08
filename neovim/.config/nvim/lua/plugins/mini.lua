return {
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({
        n_lines = 500,
        custom_textobjects = {
          a = nil,
        },
      })

      -- Autohighlight word under cursor
      require("mini.cursorword").setup()

      -- Configurable Lua functions to go forward/backward to a certain target.
      require("mini.bracketed").setup()

      -- Unshow, delete, and wipeout buffer while saving window layout
      require("mini.bufremove").setup()

      -- Move any selection in any direction
      require("mini.move").setup()

      -- Handling pairing characters
      require("mini.pairs").setup()

      -- Split and join arguments
      require("mini.splitjoin").setup()

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      require("mini.surround").setup()

      -- Simple and easy starter.
      local MiniStarter = require("mini.starter")

      local header = function()
        local hour = tonumber(vim.fn.strftime("%H"))
        local part_id = math.floor((hour + 4) / 8) + 1
        local day_part = ({ "evening", "morning", "afternoon", "evening" })[part_id]

        return ("Good %s!"):format(day_part)
      end

      MiniStarter.setup({
        silent = true,
        items = {
          MiniStarter.sections.recent_files(5, true, false),
          MiniStarter.sections.recent_files(5, false, false),
        },
        header = header,
      })

      -- Simple and easy statusline.
      require("mini.statusline").setup()

      -- Trailspace (highlight and remove)
      require("mini.trailspace").setup()
    end,
  },
}
