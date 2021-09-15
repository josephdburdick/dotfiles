local get_hl = require('utils').get_hl_color

require('lualine').setup({
    options = {
        theme = 'gruvbox-material',
        component_separators = '',
        icons_enabled = true,
    },
    sections = {
        lualine_a = {
            { 'mode', color = { gui = 'bold' } },
        },
        lualine_b = {
            { 'branch' },
            { 'diff', colored = false },
        },
        lualine_c = {
            { 'filename', file_status = true },
            {
                'diagnostics',
                sources = { 'coc' },
                diagnostics_color = {
                    error = { fg = get_hl('ErrorMsg', 'fg') },
                    warn = { fg = get_hl('WarningMsg', 'fg') },
                },
            },
        },
        lualine_x = {
            'g:coc_status',
            'filetype',
            'encoding',
            'fileformat',
        },
        lualine_y = { 'progress' },
        lualine_z = {
            { 'location', color = { gui = 'bold' } },
        },
    },
    extensions = { 'quickfix', 'nvim-tree' },
})
