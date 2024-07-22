local W = require('wezterm')

return {
    enable_scroll_bar = false,
    enable_tab_bar = false,
    enable_csi_u_key_encoding = true,
    hide_tab_bar_if_only_one_tab = true,
    audible_bell = 'Disabled',
    -- check_for_updates = false,
    font_size = 13,
    line_height = 1.1,
    font = W.font({
        family = 'Fira Code',
        harfbuzz_features = {
            'cv04',
            'cv10',
            'ss04',
            'ss03',
            'cv25',
            'cv32',
            'cv28',
            'ss06',
            'ss07',
        },
    }),
    window_padding = {
        right = 0,
        left = 0,
        top = 0,
        bottom = 0,
    },
    color_scheme = 'Tokyonight',
    keys = {
        { key = '|', mods = 'SHIFT|ALT', action = W.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
        { key = '_', mods = 'SHIFT|ALT', action = W.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    },
}
