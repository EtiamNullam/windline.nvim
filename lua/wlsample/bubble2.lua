local windline = require('windline')
local helper = require('windline.helpers')
local sep = helper.separators
local vim_components = require('windline.components.vim')

local b_components = require('windline.components.basic')
local state = _G.WindLine.state

local lsp_comps = require('windline.components.lsp')
local git_comps = require('windline.components.git')

local hl_list = {
    Black = { 'white', 'black' },
    White = { 'black', 'white' },
    Inactive = { 'InactiveFg', 'InactiveBg' },
    Active = { 'ActiveFg', 'ActiveBg' },
}
local basic = {}

basic.divider = { b_components.divider, '' }
basic.space = { ' ', '' }
basic.bg = { ' ', 'StatusLine' }
basic.file_name_inactive = { b_components.full_file_name, hl_list.Inactive }
basic.line_col_inactive = { b_components.line_col, hl_list.Inactive }
basic.progress_inactive = { b_components.progress, hl_list.Inactive }

basic.vi_mode = {
    hl_colors = {
        Normal = { 'black', 'red', 'bold' },
        Insert = { 'black', 'green', 'bold' },
        Visual = { 'black', 'yellow', 'bold' },
        Replace = { 'black', 'blue_light', 'bold' },
        Command = { 'black', 'magenta', 'bold' },
        NormalBefore = { 'red', 'black' },
        InsertBefore = { 'green', 'black' },
        VisualBefore = { 'yellow', 'black' },
        ReplaceBefore = { 'blue_light', 'black' },
        CommandBefore = { 'magenta', 'black' },
        NormalAfter = { 'white', 'red' },
        InsertAfter = { 'white', 'green' },
        VisualAfter = { 'white', 'yellow' },
        ReplaceAfter = { 'white', 'blue_light' },
        CommandAfter = { 'white', 'magenta' },
    },
    text = function()
        return {
            { sep.left_rounded, state.mode[2] .. 'Before' },
            { state.mode[1] .. ' ', state.mode[2] },
        }
    end,
}

basic.lsp_diagnos = {
    name = 'diagnostic',
    width = 90,
    text = function(bufnr)
        if lsp_comps.check_lsp(bufnr) then
            return {
                { lsp_comps.lsp_error({ format = '  %s' }), { 'red', 'black' } },
                { lsp_comps.lsp_warning({ format = '  %s' }), { 'yellow' } },
                { lsp_comps.lsp_hint({ format = '  %s' }), { 'blue' } },
            }
        end
        return ''
    end,
}

local icon_comp = b_components.cache_file_icon({
    default = '',
    hl_colors = { 'white', 'black_light' },
})

basic.file = {
    text = function(bufnr)
        return {
            { ' ', { 'white', 'black_light' } },
            icon_comp(bufnr),
            { ' ' ,{'white', 'black_light'}},
            { b_components.cache_file_name('[No Name]', '') },
            { b_components.file_modified(' ') },
            { b_components.cache_file_size() },
        }
    end,
}

basic.right = {
    text = function()
        return {
            { b_components.line_col_lua, { 'black', 'white_light' } },
            { sep.right_rounded, { 'white_light', 'black' } },
        }
    end,
}

basic.git = {
    name = 'git',
    width = 90,
    text = function(bufnr)
        if git_comps.is_git(bufnr) then
            return {
                { git_comps.diff_added({ format = '  %s' }), { 'green', 'black' } },
                { git_comps.diff_removed({ format = '  %s' }), { 'red' } },
                { git_comps.diff_changed({ format = ' 柳%s' }), { 'blue' } },
            }
        end
        return ''
    end,
}

basic.logo = {
    text = function()
        return {
            { sep.left_rounded, { 'blue', 'black' } },
            { ' ', { 'black', 'blue' } },
        }
    end,
}

local default = {
    filetypes = { 'default' },
    active = {
        { ' ', hl_list.Black },
        basic.logo,
        basic.file,
        { vim_components.search_count(), { 'red', 'black_light' } },
        { sep.right_rounded, { 'black_light', 'black' } },
        basic.lsp_diagnos,
        basic.git,
        basic.divider,
        { git_comps.git_branch({ icon = '  ' }), { 'green', 'black' }, 90 },
        { ' ', hl_list.Black },
        basic.vi_mode,
        basic.right,
        { ' ', hl_list.Black },
    },
    inactive = {
        basic.file_name_inactive,
        basic.divider,
        basic.divider,
        basic.line_col_inactive,
        { '', { 'white', 'InactiveBg' } },
        basic.progress_inactive,
    },
}

local quickfix = {
    filetypes = { 'qf', 'Trouble' },
    active = {
        { '🚦 Quickfix ', { 'white', 'black' } },
        { helper.separators.slant_right, { 'black', 'black_light' } },
        {
            function()
                return vim.fn.getqflist({ title = 0 }).title
            end,
            { 'cyan', 'black_light' },
        },
        { ' Total : %L ', { 'cyan', 'black_light' } },
        { helper.separators.slant_right, { 'black_light', 'InactiveBg' } },
        { ' ', { 'InactiveFg', 'InactiveBg' } },
        basic.divider,
        { helper.separators.slant_right, { 'InactiveBg', 'black' } },
        { '🧛 ', { 'white', 'black' } },
    },
    always_active = true,
    show_last_status = true,
}

local explorer = {
    filetypes = { 'fern', 'NvimTree', 'lir' },
    active = {
        { '  ', { 'white', 'black' } },
        { helper.separators.slant_right, { 'black', 'black_light' } },
        { b_components.divider, '' },
        { b_components.file_name(''), { 'white', 'black_light' } },
    },
    always_active = true,
    show_last_status = true,
}
windline.setup({
    colors_name = function(colors)
        -- ADD MORE COLOR HERE ----
        return colors
    end,
    statuslines = {
        default,
        quickfix,
        explorer,
    },
})
