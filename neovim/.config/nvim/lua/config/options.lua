-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
if vim.g.neovide then
  vim.o.guifont = "FiraCode Nerd Font:h14"
  vim.o.visualbell = true
  vim.opt.linespace = 2
  -- vim.g.neovide_padding_top = 20
  -- vim.g.neovide_padding_bottom = 20
  -- vim.g.neovide_padding_right = 10
  -- vim.g.neovide_padding_left = 10

  -- vim.g.neovide_scroll_animation_length = 0.2

  vim.g.neovide_floating_shadow = true

  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_remember_window_size = true
  vim.g.neovide_fullscreen = false

  vim.g.neovide_input_use_logo = true

  vim.g.neovide_cursor_antialiasing = false
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.5
  vim.g.neovide_position_animation_length = 0.0
  vim.g.neovide_scroll_animation_length = 0.0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode

  -- vim.g.neovide_cursor_trail_size = 0

  vim.g.neovide_transparency = 0.92
  vim.g.neovide_window_blurred = true
  vim.g.neovide_floating_blur_amount_x = 0.1
  vim.g.neovide_floating_blur_amount_y = 0.1
  --
end
