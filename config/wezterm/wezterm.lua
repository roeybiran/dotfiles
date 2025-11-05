local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_cursor_style = 'SteadyBar'
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'

config.enable_scroll_bar = true
config.window_padding = {
    left = 0,
    right = "2cell",
    top = 0,
    bottom = 0,
}

wezterm.on('bell', function(window, pane)
    window:toast_notification("WezTerm", "Bell rang!", nil, 4000)
end)

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.

local function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function replace_home_with_tilde(path)
    local home = os.getenv("HOME")
    if home and path:sub(1, #home) == home then
        return "~" .. path:sub(#home + 1)
    end
    return path
end

local function tab_title(tab)
    local title = tab.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    local pane_info = tab.active_pane;
    if not pane_info.current_working_dir then -- when in debug overlay
        return ''
    end
    local cwd = pane_info.current_working_dir.file_path
    local proc = pane_info.foreground_process_name or ''
    return cwd and replace_home_with_tilde(cwd) .. ' — ' .. basename(proc) or basename(proc)
end

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    return tab_title(tab)
end)

wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
        local title = tab_title(tab)
        return title
    end
)

local function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Builtin Solarized Dark'
    else
        return 'Builtin Solarized Light'
    end
end

local function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end

config.color_schemes = {}

for _, name in pairs({'Builtin Solarized Light', 'Builtin Solarized Dark'}) do
    local scheme = wezterm.get_builtin_color_schemes()[name]
    scheme.copy_mode_active_highlight_bg = { AnsiColor = 'Yellow' }
    scheme.copy_mode_active_highlight_fg = { AnsiColor = 'White' }
    scheme.copy_mode_inactive_highlight_bg = { AnsiColor = 'Yellow' }
    scheme.copy_mode_inactive_highlight_fg = { AnsiColor = 'Black' }
    scheme.quick_select_label_bg = { AnsiColor = 'Yellow' }
    scheme.quick_select_label_fg = { AnsiColor = 'Black' }
    scheme.quick_select_match_bg = { AnsiColor = 'Yellow' }
    scheme.quick_select_match_fg = { AnsiColor = 'Black' }
    config.color_schemes[name] = scheme
end

config.color_scheme = scheme_for_appearance(get_appearance())

wezterm.log_info("bar")

-- Disable ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.keys = {
    {
        key = 'g',
        mods = 'ALT',
        action = wezterm.action.PaneSelect,
    },
    {
        key = 'Enter',
        mods = 'ALT',
        action = 'DisableDefaultAssignment',
    },
    {
        key = 'f',
        mods = 'ALT',
        action = wezterm.action.QuickSelect,
    },
    {
        key = 'c',
        mods = 'ALT',
        action = wezterm.action.ActivateCopyMode,
    },
    {
        key = 'd',
        mods = 'SUPER',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'd',
        mods = 'SUPER|SHIFT',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
        key = ']',
        mods = 'SUPER',
        action = wezterm.action.ActivatePaneDirection 'Next',
    },
    {
        key = '[',
        mods = 'SUPER',
        action = wezterm.action.ActivatePaneDirection 'Prev',
    },
    {
        key = 'w',
        mods = 'SUPER',
        action = wezterm.action.CloseCurrentPane { confirm = false },
    },
    {
        key = 'k',
        mods = 'SUPER',
        action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
    },
    {
        key = 'w',
        mods = 'SUPER|SHIFT',
        action = wezterm.action.CloseCurrentTab { confirm = false },
    },
    {
        key = 'f',
        mods = 'SUPER',
        action = wezterm.action.Search {
            Regex = '',
        },
    },
}

return config
